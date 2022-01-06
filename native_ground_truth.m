function m_ground_truth = native_ground_truth(m_in)
    s = size(m_in);
    x_w = int16(s(1));
    y_w = int16(s(2));
    cc = bwconncomp(m_in);
    n = cc.NumObjects;
    my_ccs = zeros(x_w, y_w, n);
    coms = zeros(n, 2);
    for i=1:n % Per connected component
      my_cc = zeros(size(m_in));
      indices = cc.PixelIdxList{i};
      [row, col] = ind2sub(size(m_in), indices); % Linear indices to index 2-tuple
      for j=1:numel(row)
        my_cc(row(j), col(j)) = 1;
      end
      my_ccs(:, :, i) = my_cc; % Reconstruct connected components on stack
      my_indices = find(my_cc);
      [my_com_x, my_com_y] = ind2sub(size(m_in), indices);
      coms(i, :) = [int16(mean(my_com_x)) int16(mean(my_com_y))];
    end
    x_max = max(coms(:, 1)); % Define bbox of cell as rect
    y_max = max(coms(:, 2));
    x_min = min(coms(:, 1));
    y_min = min(coms(:, 2));

    new_cc = zeros(size(cc));
    for i=1:n
      to_displace = my_ccs(:, :, i);
      new_com = [randi([1, x_w]), randi([1, y_w])];
      displacement = coms(i, :) - new_com;
      to_displace = circshift(to_displace, displacement);

      check_if_all_box = @(m) sum(sum(m(x_min:x_max, y_min:y_max))) == sum(sum(m)); % If all pixels within box (metric conserved)
      while ~check_if_all_box(to_displace) % Circularly shift until metric is conserved
        new_com = [randi([1, x_w]), randi([1, y_w])];
        displacement = coms(i, :) - new_com;
        to_displace = circshift(to_displace, displacement);
      end
      new_cc = new_cc + to_displace;
    end
    m_ground_truth = new_cc;
end

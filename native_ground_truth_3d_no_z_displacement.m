function m_ground_truth = native_ground_truth_3d_no_z_displacement(m_in)
   
    m_ground_truth = zeros(size(m_in));
    s = size(m_in);
    x_w = s(1);
    y_w = s(2);
    z_w = s(3);
    cc = bwconncomp(m_in);
    n = cc.NumObjects;
    if n < 2
      m_ground_truth = m_in
      return
    end

    coms = zeros(n, 3);
    for i=1:n
      obj = cc.PixelIdxList{i};
      [x, y, z] = ind2sub(size(m_in), obj);
      coms(i, 1) = round(mean(x));
      coms(i, 2) = round(mean(y));
      coms(i, 3) = round(mean(z));
    end
    indices_com = sub2ind(s, coms(:, 1), coms(:, 2), coms(:, 3));

    sups = max(coms, [],  1);
    infs = min(coms, [],  1);
    new_positions = round((sups - infs).*rand(n, 3) + ones(n, 3).*infs); % Generate new positions in bounding box
    displacement_vector = new_positions - coms; % Compute displacement
    % issue with subsetting of 2D matrix: displacement_vector(3) = 0; % No displacement in z-dimension allowed
    displacement_vector(:,3) = 0; % No displacement in z-dimension allowed
    for i=1:n
      ids = cc.PixelIdxList{i};
      [x, y, z] = ind2sub(s, ids);%added semi column
      for j=1:numel(x)
        new_pos = [x(j) y(j) z(j)] + displacement_vector(i,:);
        if (0 < new_pos(1)) && (new_pos(1) < x_w) && (0 < new_pos(2)) && (new_pos(2) < y_w) % Ignore pixel if outside of image
            %2D subsetting: m_ground_truth(x(j) + displacement_vector(1), y(j) + displacement_vector(2), z(j)) = 1;
            m_ground_truth(x(j) + displacement_vector(i,1), y(j) + displacement_vector(i,2), z(j)) = 1;
        end
      end
    end
end

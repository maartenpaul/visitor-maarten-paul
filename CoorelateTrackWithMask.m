function trackData = CoorelateTrackWithMask(trackData,imBW,pixelSize_um_xyz,verbose)
    if (~exist('verbose','var') || isempty(verbose))
        verbose = false;
    end

    for i=1:length(trackData)
        curPos_xyz = trackData(i).pos_xyz;
        frames = trackData(i).frames;
        damaged = false(length(frames),1);
        for j=1:length(frames)
            curP = curPos_xyz(j,:)./pixelSize_um_xyz;
            curP = round(curP);
            curP(3) = min(9,max(1,curP(3)));
            t = frames(j) +1;
            damaged(j) = imBW(curP(2),curP(1),curP(3),1,t);
        end
        
        trackData(i).inMask = damaged;
        
        if (~verbose)
            continue
        end
        
        ind = find(damaged);
        if (~isempty(ind))
            fprintf('Track %d, frames:',i);
            for j=1:length(ind)
                fprintf('%d, ',ind(j));
            end
            fprintf('\n');
        end
    end
end

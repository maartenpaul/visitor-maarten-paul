function matToTrackData(rootDir,conditionName)
filename =  fullfile(rootDir,[conditionName,'_tracks.mat']);
    if isfile(filename)
         % File exists.
        load(filename,'trackData');

        outStr = 'trackID,pos_x,pos_y,pos_z,time,frame,step_x,step_y,step_z,inMask\n';
        expression = ('%d,%f,%f,%f,%f,%d,%f,%f,%f,%d\n');

        for track = 1:length(trackData)
            curTrack = trackData(track);
            trackID = curTrack.trackID;

            pos_xyz = curTrack.pos_xyz(1,:);
            time = curTrack.times(1);
            frame = curTrack.frames(1);
            if (isfield(curTrack,'inMask'))
                mask = curTrack.inMask(1);
            else
                mask = false;
            end
            curStr = sprintf(expression,trackID,pos_xyz(1),pos_xyz(2),pos_xyz(3),time,frame,[],[],[],mask);
            outStr = [outStr, curStr];
            for i=1:length(curTrack.inMask)-1
                pos_xyz = curTrack.pos_xyz(i+1,:);
                step_xyz = curTrack.steps_xyz(i,:);
                time = curTrack.times(i+1);
                frame = curTrack.frames(i+1);

                if (isfield(curTrack,'inMask'))
                    mask = curTrack.inMask(i+1);
                else
                    mask = false;
                end

                curStr = sprintf(expression,trackID,pos_xyz(1),pos_xyz(2),pos_xyz(3),time,frame,step_xyz(1),step_xyz(2),step_xyz(3),mask);

                outStr = [outStr, curStr];
            end
        end

        f = fopen(fullfile(rootDir,[conditionName,'_tracks_mask.csv']),'wt');
        fprintf(f,outStr);
        fclose(f);
    end
end
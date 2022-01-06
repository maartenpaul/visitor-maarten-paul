function saveTrackData2(rootDir,conditionName,trackData)
    save(fullfile(rootDir,[conditionName,'_tracks.mat']),'trackData');
    
    outStr = 'trackID,pos_x,pos_y,pos_z,time,frame,step_x,step_y,step_z,inMask,rawInt,meanInt,normInt,sdInt,maxInt,minInt,distMask,invDistMask\n';
    expression = ('%d,%f,%f,%f,%f,%d,%f,%f,%f,%d,%f,%f,%f,%f,%f,%f,%f,%f\n');
    
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
        rawInt=curTrack.rawInt(1);
        meanInt=curTrack.meanInt(1);
        normInt=curTrack.normInt(1);
        sdInt=curTrack.sdInt(1);
        maxInt=curTrack.maxInt(1);
        minInt=curTrack.minInt(1);
        distMask=curTrack.distMask(1);
        invDistMask=curTrack.invDistMask(1);
        
        curStr = sprintf(expression,trackID,pos_xyz(1),pos_xyz(2),pos_xyz(3),time,frame,[],[],[],mask,rawInt,meanInt,normInt,sdInt,maxInt,minInt,distMask,invDistMask);
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
            rawInt=curTrack.rawInt(i+1);
            meanInt=curTrack.meanInt(i+1);
            normInt=curTrack.normInt(i+1);
            sdInt=curTrack.sdInt(i+1);
            maxInt=curTrack.maxInt(i+1);
            minInt=curTrack.minInt(i+1);
            distMask=curTrack.distMask(i+1);
            invDistMask=curTrack.invDistMask(i+1);

            curStr = sprintf(expression,trackID,pos_xyz(1),pos_xyz(2),pos_xyz(3),time,frame,step_xyz(1),step_xyz(2),step_xyz(3),mask,rawInt,meanInt,normInt,sdInt,maxInt,minInt,distMask,invDistMask);
            
            outStr = [outStr, curStr];
        end
    end
    
    f = fopen(fullfile(rootDir,[conditionName,'_tracks_mask2.csv']),'wt');
    fprintf(f,outStr);
    fclose(f);
end

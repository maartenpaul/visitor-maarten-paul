function SaveResults(rootDir,conditionName,trackData,results,locationError)
    save(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),'trackData','results','locationError');
    
    outStr = 'trackID,pos_x,pos_y,pos_z,time,frame,step_x,step_y,step_z,diffusionConst,velocity,state,inMask\n';
    expression = ('%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%s,%d\n');
    
    for track = 1:length(trackData)
        curTrack = trackData(track);
        trackID = curTrack.trackID;
        if (isempty(curTrack.state))
            continue
        end
        
        pos_xyz = curTrack.pos_xyz(1,:);
        time = curTrack.times(1);
        frame = curTrack.frames(1);
        dConst = curTrack.dConst(1);
        vel = curTrack.velocity(1);
        state = curTrack.state{1};
        if (isfield(curTrack,'inMask'))
                mask = curTrack.inMask(1);
            else
                mask = false;
            end
        curStr = sprintf(expression,trackID,pos_xyz(1),pos_xyz(2),pos_xyz(3),time,frame,[],[],[],dConst,vel,state,mask);
        outStr = [outStr, curStr];
        
        
        for i=1:length(curTrack.state)
            pos_xyz = curTrack.pos_xyz(i+1,:);
            step_xyz = curTrack.steps_xyz(i,:);
            time = curTrack.times(i+1);
            frame = curTrack.frames(i+1);
            dConst = curTrack.dConst(i+1);
            vel = curTrack.velocity(i+1);
            state = curTrack.state{i+1};
            if (isfield(curTrack,'inMask'))
                mask = curTrack.inMask(i+1);
            else
                mask = false;
            end
            
            curStr = sprintf(expression,trackID,pos_xyz(1),pos_xyz(2),pos_xyz(3),time,frame,step_xyz(1),step_xyz(2),step_xyz(3),dConst,vel,state,mask);
            
            outStr = [outStr, curStr];
        end
    end
    
    f = fopen(fullfile(rootDir,[conditionName,'_hhm-bayes.csv']),'wt');
    fprintf(f,outStr);
    fclose(f);
end

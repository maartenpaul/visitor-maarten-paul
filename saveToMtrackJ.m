function saveToMtrackJ(rootDir,conditionName,trackData,cropFromEdge,startFrame,min_length)
    txtfile = (fullfile(rootDir,[conditionName '.mdf']));
    fid = fopen(txtfile,'wt');
    fprintf(fid,'MTrackJ 1.5.0 Data File \n');
    fprintf(fid,'Assembly 1\n');
    fprintf(fid,'Cluster 1\n');
    b=0;
    for track = 1:length(trackData)
        curTrack = trackData(track);
        if(any(curTrack.inMask))
            trackData(track).trackInMask = 1;
            b=b+1;
        else
            trackData(track).trackInMask = 0;
        end
        
    end
    disp(['number of tracks inside is:' num2str(b) ' in total:' num2str(length(trackData))]);
    for track = 1:length(trackData)
        curTrack = trackData(track);
        if (length(curTrack.frames)<min_length||curTrack.trackInMask==1)
            continue
        end
        trackID = curTrack.trackID;
        fprintf(fid,['Track ',num2str(trackID),'\n']);
        
        x =  curTrack.pos_xyz(:,1);
        y =  curTrack.pos_xyz(:,2);
        z =  curTrack.pos_xyz(:,3);
        frames = curTrack.frames+startFrame;
        inMask = curTrack.inMask;
        
        for j=1:length(x)
            fprintf(fid,['Point ',num2str(j),' ',num2str((x(j)/0.12)+cropFromEdge),' ',num2str((y(j)/0.12)+cropFromEdge),' ',num2str(inMask(j)),' ',num2str(frames(j)+1),' 1\n']);
        end
    end
    
    fprintf(fid,'Cluster 2\n');
    
    for track = 1:length(trackData)
        curTrack = trackData(track);
        if (length(curTrack.frames)<min_length||curTrack.trackInMask==0)
            continue
        end
        trackID = curTrack.trackID;
        fprintf(fid,['Track ',num2str(trackID),'\n']);
        
        x =  curTrack.pos_xyz(:,1);
        y =  curTrack.pos_xyz(:,2);
        z =  curTrack.pos_xyz(:,3);
        frames = curTrack.frames+startFrame;
        inMask = curTrack.inMask;
        
        for j=1:length(x)
            fprintf(fid,['Point ',num2str(j),' ',num2str((x(j)/0.12)+8),' ',num2str((y(j)/0.12)+8),' ',num2str(inMask(j)),' ',num2str(frames(j)+1),' 1\n']);
        end
    end
    fprintf(fid,'End of MTrackJ File');
    fclose(fid);
      
    
end


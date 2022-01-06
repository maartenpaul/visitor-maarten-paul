function trackData = CoorelateTrackWithMaskMPv2(trackData,im,imBW,pixelSize_um_xyz,cropFromEdge,startFrame,verbose)
    if (~exist('verbose','var') || isempty(verbose))
        verbose = false;
    end

        dimIm = size(im);       
        distMap = zeros(dimIm);
        
        parfor j=1:dimIm(5)
             %Yuriy Mishchenko (2020). 3D Euclidean Distance Transform for Variable Data Aspect Ratio (https://www.mathworks.com/matlabcentral/fileexchange/15455-3d-euclidean-distance-transform-for-variable-data-aspect-ratio), MATLAB Central File Exchange. Retrieved March 6, 2020. 
              distMap(:,:,:,1,j) = bwdistsc(imBW(:,:,:,1,j),pixelSize_um_xyz);
        end
       
        
        meanIntArray = zeros(9,dimIm(5));
        normIntArray = zeros(9,dimIm(5));
        sdIntArray = zeros(9,dimIm(5));
        maxIntArray = zeros(9,dimIm(5));
        minIntArray = zeros(9,dimIm(5));
        parfor j=1:dimIm(5)
           for k=1:9
               meanIntArray(k,j) = mean(im(:,:,k,1,j),'all');
               normIntArray(k,j) = mean(im(:,:,k,1,j),'all')/max(im(:,:,:,1,j),[],'all');
               sdIntArray(k,j) =    std(im(:,:,k,1,j),1,'all');
               maxIntArray(k,j) = max(im(:,:,k,1,j),[],'all');
               minIntArray(k,j) = min(im(:,:,k,1,j),[],'all');
           end
        end
        
        
    
    
    for i=1:length(trackData)
        curPos_xyz = trackData(i).pos_xyz;
        frames = trackData(i).frames;
        damaged = false(length(frames),1);
        rawInt = zeros(length(frames),1);
        meanInt = zeros(length(frames),1);
        normInt = zeros(length(frames),1);
        maxInt  = zeros(length(frames),1);
        minInt = zeros(length(frames),1);
        sdInt = zeros(length(frames),1);
        distMask = zeros(length(frames),1);

        for j=1:length(frames)
            curP = curPos_xyz(j,:)./pixelSize_um_xyz;
            curP = round(curP);
            curP(1) = curP(1)+cropFromEdge;
            curP(2) = curP(2)+cropFromEdge;
            curP(3) = min(9,max(1,curP(3)));
            t = frames(j) +1+startFrame;
            damaged(j) = imBW(curP(2),curP(1),curP(3),1,t);
            rawInt(j) = im(curP(2),curP(1),curP(3),1,t);
            normInt = im(curP(2),curP(1),curP(3),1,t);
            meanInt(j) = meanIntArray(curP(3),t);
            sdInt(j) = sdIntArray(curP(3),t);
            maxInt(j) = maxIntArray(curP(3),t);
            minInt(j) =  minIntArray(curP(3),t);
            distMask(j) = distMap(curP(2),curP(1),curP(3),1,t);
        end
        
        trackData(i).inMask = damaged;
        trackData(i).rawInt = rawInt;
        trackData(i).meanInt = meanInt;
        trackData(i).normInt = normInt;
        trackData(i).sdInt = sdInt;
        trackData(i).maxInt = maxInt;
        trackData(i).minInt = minInt;
        trackData(i).distMask = distMask;
        
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

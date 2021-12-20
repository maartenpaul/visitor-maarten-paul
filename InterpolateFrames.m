function im = InterpolateFrames(rootDir,h5Name,useFirstframe)
    if isempty(useFirstframe)
        useFirstframe = false;
    end
    % Damage frames interpolate
    imDamage = MFMh5Import(rootDir,h5Name);
    
    imD = MicroscopeData.MakeMetadataFromImage(imDamage);
    imD.PixelPhysicalSize = [0.120,0.120,0.420];
    imSz = imD.Dimensions;
    if useFirstframe==true
        imDamage(:,:,:,:,1:imD.NumberOfFrames)=repmat(imDamage(:,:,:,:,1),[1,1,1,1,imD.NumberOfFrames]);
        im = imDamage;
    else
        means = zeros(imD.NumberOfFrames,1);
        for t=1:imD.NumberOfFrames
            curIm = imDamage(:,:,:,:,t);
            means(t) = mean(curIm(:));
        end
        meansNorm = means-min(means(:));
        meansNorm = meansNorm./max(meansNorm(:));

        h = fspecial('log',[15,1],1.25)';
        l = filter(h,1,meansNorm);
        bw = l<-0.2;
        bw = bw(8:end);
        frames = find(bw);
        frames = frames(frames>10);

        goodFrames = imDamage(:,:,:,:,frames);
        clear('imDamage')

        [X,Y,Z,T] = ndgrid(1:imSz(1),1:imSz(2),1:imSz(3),1:size(goodFrames,5));

        intFrames = [];
        for f=1:length(frames)-1
            stepSize = 1/(frames(f+1)-frames(f));
            curSteps = 1+stepSize:stepSize:2;
            intFrames = [intFrames,curSteps+f-1];
        end

        [Xq,Yq,Zq,Tq] = ndgrid(1:imSz(1),1:imSz(2),1:imSz(3),intFrames);
        im = interpn(X,Y,Z,T,squeeze(goodFrames),Xq,Yq,Zq,Tq,'makima');
        im = permute(im,[1,2,3,5,4]);

        firstFrames = repmat(im(:,:,:,:,1),[1,1,1,1,frames(1)-1]);
        lastFrames = repmat(im(:,:,:,:,end),[1,1,1,1,imD.NumberOfFrames-frames(end)+1]);
        im = cat(5,firstFrames,im,lastFrames);
    end
    
end

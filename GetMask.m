function imBW = GetMask(im,sigmas,thresh)
    if (~exist('sigmas','var') || isempty(sigmas))
        sigmas = [1,1,0.75];
    end
    if (~exist('thresh','var') || ismepty(thresh))
        thresh = -0.02;
    end
    
    imE = HIP.LoG(mat2gray(im),sigmas,[]);
    imBW = imE < thresh;

    se = strel('disk',1);
    for t=1:size(imBW,5)
        curBW = imBW(:,:,:,1,t);
        curBW = imopen(curBW,se);
        rp = regionprops3(curBW,'Volume','VoxelIdx');
        ind = rp.VoxelIdxList(rp.Volume>10);
        ind = vertcat(ind{:});
        curBW = false(size(curBW));
        curBW(ind) = true;
        imBW(:,:,:,1,t) = curBW;
    end
end

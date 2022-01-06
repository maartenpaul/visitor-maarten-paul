function [im,imD] = MFMh5Import(pathname,filename)
    if (~exist('pathname','var') || isempty(pathname))
        [filename,pathname] = uigetfile('*.h5','Choose HDF5 file to open');
    end

    info = h5info(fullfile(pathname,filename));
    dataset1 = info.Datasets(1).Name;
    img1 = h5read(fullfile(pathname,filename),['/' dataset1]);
    stacksize = size(img1);
    clear img1;
    numstacks = length(info.Datasets);
    data = zeros([stacksize numstacks]);
    prgs = Utils.CmdlnProgress(numstacks,true,'Reading H5');
    for a = 1:numstacks
        data(:,:,:,a) = h5read(fullfile(pathname,filename),['/' info.Datasets(a).Name]);
        prgs.PrintProgress(a);
    end
    prgs.ClearProgress(true);
    
    if (ndims(data)==4)
        data = permute(data,[1,2,3,5,4]);
    end
    
    im = data;
    imD = MicroscopeData.MakeMetadataFromImage(im);
    [~,imD.DatasetName] = fileparts(filename);
    
    imD.PixelPhysicalSize = [0.12, 0.12, 0.4];
end

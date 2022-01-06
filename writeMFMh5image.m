function writeMFMh5image(im,pathname,filesave,bits)

    dim = size(im);
    h= dim(1);
    w= dim(2);
    planes = dim(3);
    frameread = (1:1:dim(5));
    channel = 1;
    leadingzeros = floor(log10(length(frameread))) + 1;



    imgs1 = im;
    imgs1 = squeeze(imgs1);
    foo = waitbar(0,'Saving HDF5...');

    disp('Saving...');
    if exist(fullfile(pathname,filesave),'file')
        warning('File already exists, overwriting...');
        delete(fullfile(pathname,filesave));
    end
    for a = frameread
        filenum = sprintf(['%0' num2str(leadingzeros) 'd'],a);
        dataset = ['/time' filenum];
        h5create(fullfile(pathname,filesave),dataset,[h w planes],'Datatype',bits);
        h5write(fullfile(pathname,filesave),dataset,double(imgs1(:,:,:,a)));
        waitbar(a/max(frameread),foo);
        %parfor_progress;
    end
    delete(foo); 
end
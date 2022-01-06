function writeMFMtiffimage(im,pathname,filesave,bits)

    dim = size(im);
    h= dim(1);
    w= dim(2);
    planes = dim(3);
    frameread = (1:1:dim(5));
    channel = 1;
    leadingzeros = floor(log10(length(frameread))) + 1;



    imgs1 = im;
    
    

    disp('Saving...');
    if exist(fullfile(pathname,filesave),'file')
        warning('File already exists, overwriting...');
        delete(fullfile(pathname,filesave));
    end
if(bits=="uint16")
        bfsave(uint16(imgs1),fullfile(pathname,filesave),'dimensionOrder', 'XYZCT');
else if (bits=="uint8")
        bfsave(uint8(imgs1),fullfile(pathname,filesave),'dimensionOrder', 'XYZCT');
    end
    
end
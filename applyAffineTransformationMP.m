function I_tr__ = applyAffineTransformationMP(I__,random)
    I_app__ = [I__ I__ I__
            I__ I__ I__
            I__ I__ I__];
    cb_ref = imref2d(size(I__));
    
    xs = size(I__);
    ys = size(I__);
    xss = xs(1);
    yss = xs(2);
    cb_ref.XWorldLimits = cb_ref.XWorldLimits + xss;
    cb_ref.YWorldLimits = cb_ref.YWorldLimits + yss;
    
    r_x = 0;%randi(x_max);
    r_y = 0;%randi(y_max);
    if nargin==2
        r_t = 2*pi*random;
    elseif nargin==1
        r_t = 2*pi*rand(1);
    end
        
    
    I_app__ = imrotate(I_app__, r_t/(2*pi)*360, 'crop');
    
    tr_mat__ = [ 1  0 0
                0  1 0
                r_x r_y 1];
    tr_trafo = affine2d(tr_mat__);
    I_tr__ = imwarp(I_app__, tr_trafo, 'OutputView', cb_ref);
end


function PlotTracks(im, trackData, pixelPhysicalSize, outPath)

    f1 = figure;
    ph = plot(0,0);
    s1 = get(ph,'parent');

    hold on
    title('Color:Velocity     Width:Diffusion Const    Asterisk:In Damaged Area');

    f2 = figure;
    ph = plot(0,0);
    s2 = get(ph,'parent');
    hold on
    title('Color:Diffusion Const     Width:Velocity    Asterisk:In Damaged Area');

    numBins = 2^10;

    dRange = [trackData.dConst];
    [N,edges] = histcounts(dRange,numBins);
    n = cumsum(N)./sum(N(:));
    dMaxInd = find(n>0.999,1,'first');
    dEdgeStep = edges(2)-edges(1);
    numDconstColors = dMaxInd;
    padN = round(numDconstColors*0.3);
    clorD = jet(numDconstColors+padN);
    clorD = clorD(padN+1:end,:);

    vRange = [trackData.velocity];
    [N,edges] = histcounts(vRange,numBins);
    n = cumsum(N)./sum(N(:));
    vMaxInd = find(n>0.999,1,'first');
    vEdgeStep = edges(2)-edges(1);
    numVelColors = vMaxInd;
    padN = round(numVelColors*0.3);
    clorV = jet(numVelColors+padN);
    clorV = clorV(padN+1:end,:);

    maxLineWidth = 2;

    prgs = Utils.CmdlnProgress(size(im,5),true,'Ploting tracks',true);
    for t = 1:size(im,5)-1
        for tr = 1:length(trackData)
            if (isempty(trackData(tr).dConst))
                continue
            end

            stepInd = find(trackData(tr).frames==t-1);
            if (isempty(stepInd) || stepInd>=length(trackData(tr).frames))
                continue
            end

            vel = trackData(tr).velocity(stepInd);
            d = trackData(tr).dConst(stepInd);

            pos_t0 = trackData(tr).pos_xyz(stepInd,:)./pixelPhysicalSize;
            pos_t1 = trackData(tr).pos_xyz(stepInd+1,:)./pixelPhysicalSize;

            vInd = min(vMaxInd, max(1,round(vel/vEdgeStep)));
            dInd = min(dMaxInd, max(1,round(d/dEdgeStep)));
            lineWidth = dInd/dMaxInd * maxLineWidth + 0.5;

            if (trackData(tr).inMask(stepInd))
                plot(s1,pos_t0(1),pos_t0(2),'*','color',clorV(vInd,:),'markerSize',12);
                plot(s2,pos_t0(1),pos_t0(2),'*','color',clorD(dInd,:),'markerSize',12);
            end

            plot(s1,[pos_t0(1),pos_t1(1)],[pos_t0(2),pos_t1(2)],'linewidth',lineWidth,'color',clorV(vInd,:));

            lineWidth = vInd/vMaxInd * maxLineWidth + 0.5;
            plot(s2,[pos_t0(1),pos_t1(1)],[pos_t0(2),pos_t1(2)],'linewidth',lineWidth,'color',clorD(dInd,:));
        end
        if (mod(t,20)==0)
            prgs.PrintProgress(t);
        end
    end
    prgs.ClearProgress(true);
    
    set(s1,'color','k');
    set(s2,'color','k');
    axis(s1,'image')
    axis(s2,'image')
    
    set(f1,'Units','normalized','position',[0,0,1,1]);
    set(f2,'Units','normalized','position',[0,0,1,1]);
    
    fig1 = getframe(f1);
    fig2 = getframe(f2);
    
    imwrite(fig1.cdata,fullfile(outPath,'_diffusionColor.tif'));
    imwrite(fig2.cdata,fullfile(outPath,'_velocityColor.tif'));
end


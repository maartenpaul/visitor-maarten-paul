%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
root = 'N:\Jesse\MFM\Maarten_Eric';
trackingFileName = '190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002_tracks.csv';
dnaDamageImageName = '190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002__Ch2.h5';
particleImageName = '190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002__Ch1.h5';

pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
timeBetweenFrames = 0.032;

minTrackLength = 10;
numberOfDiffusionStates = 2;

conditionName = 'test';
cropFromEdge = 8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% HMM-Bayes
trackData = HMM_Bayes.CSVimport(fullfile(root,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));
[trackData,results,locationError] = HMM_Bayes.Run(trackData,numberOfDiffusionStates,minTrackLength);
HMM_Bayes.SaveResults(root,conditionName,trackData,results,locationError);
%[trackData,results,locationError] = HMM_Bayes.LoadResults(root,conditionName);

%% Damage frames interpolate
imDamage = MFMh5Import(root,dnaDamageImageName);

imD = MicroscopeData.MakeMetadataFromImage(imDamage);
imD.PixelPhysicalSize = [0.120,0.120,0.420];
imSz = imD.Dimensions;

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
damageFramesInterp = interpn(X,Y,Z,T,squeeze(goodFrames),Xq,Yq,Zq,Tq,'makima');
damageFramesInterp = permute(damageFramesInterp,[1,2,3,5,4]);
clear('X','Y','Z','T','Xq','Yq','Zq','Tq','goodFrames')

firstFrames = repmat(damageFramesInterp(:,:,:,:,1),[1,1,1,1,frames(1)-1]);
lastFrames = repmat(damageFramesInterp(:,:,:,:,end),[1,1,1,1,imD.NumberOfFrames-frames(end)+1]);
damageFramesInterp = cat(5,firstFrames,damageFramesInterp,lastFrames);
clear('firstFrames','lastFrames')

%% Segment DNA Damage
f = figure;
pH = plot(0,0);
aH = get(pH,'parent');

sigmas = [1,1,0.75];
imE = HIP.LoG(mat2gray(damageFramesInterp),sigmas,[]);
imBW = imE < -0.02;

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

%% Correlate postions with DNA Damage
tic
for i=1:length(trackData)
    curPos_xyz = trackData(i).pos_xyz;
    frames = trackData(i).frames;
    damaged = false(length(frames),1);
    for j=1:length(frames)
        curP = curPos_xyz(j,:)./imD.PixelPhysicalSize;% + [cropFromEdge,cropFromEdge,0];
        curP = round(curP);
        curP(3) = min(9,max(1,curP(3)));
        t = frames(j) +1;
        damaged(j) = imBW(curP(2),curP(1),curP(3),1,t);
    end
    ind = find(damaged);
    if (~isempty(ind))
        fprintf('Track %d, frames:',i);
        for j=1:length(ind)
            fprintf('%d, ',ind(j));
        end
        fprintf('\n');
    end

    trackData(i).inDamagedMask = damaged;
end
fprintf('Looking up damage took %s\n',Utils.PrintTime(toc,length(trackData)));

%% Get other channel and combine
im = MFMh5Import(root,particleImageName);
im = cat(4,im,damageFramesInterp);
clear('damageFramesInterp')

%% plot
curIm = im(:,:,:,2,1);
figure
% s1 = subplot(1,2,1);
ph = plot(0,0);
s1 = get(ph,'parent');
% imagesc(max(curIm,[],3))
% colormap gray
% axis image

hold on
title('Color:Velocity Width:Diffusion Const');

% s2 = subplot(1,2,2);
figure
ph = plot(0,0);
s2 = get(ph,'parent');
% imagesc(max(curIm,[],3))
% colormap gray
% axis image
hold on
title('Color:Diffusion Const Width:Velocity');

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
        
        pos_t0 = trackData(tr).pos_xyz(stepInd,:)./imD.PixelPhysicalSize;% + [cropFromEdge,cropFromEdge,0];
        pos_t1 = trackData(tr).pos_xyz(stepInd+1,:)./imD.PixelPhysicalSize;% + [cropFromEdge,cropFromEdge,0];
        
        vInd = min(vMaxInd, max(1,round(vel/vEdgeStep)));
        dInd = min(dMaxInd, max(1,round(d/dEdgeStep)));
        lineWidth = dInd/dMaxInd * maxLineWidth + 0.5;
        
        if (trackData(tr).inDamagedMask(stepInd))
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
rootDir = 'E:\20190312\Deconvolution';
trackingFileName = 'Traj_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0001__Ch1_preprocessed.tif.csv';

objectMaskImageName = '190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0001__Ch2.h5';
particleImageName = '190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch1.h5';

pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
timeBetweenFrames = 0.052;

minTrackLength = 10;
numberOfDiffusionStates = 1;

conditionName = split(trackingFileName,'.');
conditionName =  char(conditionName(1));
cropFromEdge = 8;
startFrame = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% HMM-Bayes
trackData = HMM_Bayes.CSVimport(fullfile(rootDir,trackingFileName),'Trajectory','x','y','z','Frame',timeBetweenFrames,pixelSize(1),pixelSize(3));
[trackData,results,locationError] = HMM_Bayes.Run(trackData,numberOfDiffusionStates,minTrackLength);
HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);

% Run the following line if HMM_Bayes was already run
%[trackData,results,locationError] = HMM_Bayes.LoadResults(rootDir,conditionName);

%% Get DNA Damage Mask
im = InterpolateFrames(rootDir,objectMaskImageName);
imBW = GetMask(im);

%writeMFMh5image(im,rootDir,'im_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.h5','uint16');
writeMFMtiffimage(im,rootDir,'im_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch1.tif','uint16');

writeMFMh5image(imBW,rootDir,'im_BW_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.h5','uint8');
writeMFMtiffimage(imBW,rootDir,'imBW_190312_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0012__Ch2.tif','uint8');

%% Assosiate the masked data with the track data
trackData = CoorelateTrackWithMaskMP(trackData,imBW,pixelSize,cropFromEdge,startFrame);
%trackData = CoorelateTrackWithMask(trackData,imBW,pixelSize);
saveTrackData(rootDir,conditionName,trackData);
saveToMtrackJ(rootDir,conditionName,trackData,cropFromEdge,startFrame,4);
HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);

%% Plot (optional)
HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
PlotTracks(im,trackData,pixelSize,fullfile(rootDir,conditionName));

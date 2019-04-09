%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User Settings
rootDir = 'N:\Jesse\MFM\Maarten_Eric';
trackingFileName = '190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002_tracks.csv';
objectMaskImageName = '190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002__Ch2.h5';
particleImageName = '190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002__Ch1.h5';

pixelSize = [0.120,0.120,0.420]; % (x,y,z) in um
timeBetweenFrames = 0.032;

minTrackLength = 10;
numberOfDiffusionStates = 2;

conditionName = 'test';
cropFromEdge = 8;
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

%% Assosiate the masked data with the track data
trackData = CoorelateTrackWithMask(trackData,imBW,pixelSize);
HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);

%% Plot (optional)
HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
PlotTracks(im,trackData,pixelSize,fullfile(rootDir,conditionName));

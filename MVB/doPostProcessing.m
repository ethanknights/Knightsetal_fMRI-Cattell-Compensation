%% Purpose: Write 'data.csv' to RDir containing the full dataset 
%% i.e. unvivariate, behaviour & MVB
%% Note - each analysis has a 'data.csv' in an different RDir/<subFolder>
%% e.g.
%% RDir/70-voxels_model-sparse
%% RDir/70-voxels_model-smooth  
%% RDir/70-voxels_model-sparse_controlVoxelSize
%%
%% flag_dropMVBSubjects = 1 (exclude subjects who fail MVB decoding from all analyses) | 0 (dont exclude these subjects at all, even in MVB)
%% ========================================================================
clear

%% Ensure 'data.csv' saved to a sensible R/<subFolder> with appropriate data
flag_dropMVBSubjects = 1;

T = readtable('T_withROIs.csv');
CCIDList = T.SubCCIDc;

%% 001 - RDir/70-voxels_model-sparse
RDirSubFolder = '70voxel_model-sparse';
ROINames = {'taskMap_24POINT8','compensationROI','taskMap_24POINT8&compensationROI'};
model = 'sparse'; % 'sparse' | 'smooth'


%% Main code
%% ========================================================================
RDir = fullfile('R',sprintf('dropMVBSubjects-%d',flag_dropMVBSubjects),RDirSubFolder,'csv');
mkdir(RDir)


%% MVB decoding mapping: Bilateral
%% ========================================================================
groupFvals = [];
for s = 1:length(CCIDList)
  load(sprintf('data/%s/MVB_%s_con3_Hard-Easy_model-%s.mat',CCIDList{s},ROINames{3},model),'MVB');
  groupFvals(s) = MVB.Fvals;
end
groupFvals = groupFvals';
% mean(groupFvals) ; median(groupFvals)
% [H,P,CI,STATS] = ttest(groupFvals,3,'tail','right')
% [P,H] = signtest(groupFvals,3,'alpha',0.05,'tail','right') %Non-parametric
% figure('Position',[10 10 900 600]),hist(groupFvals,30);
violinplot(groupFvals)
idx_couldNotDecode = groupFvals < 3; %to exclude from boost analysis
find(idx_couldNotDecode)

%% MVB: Get voxel weights' spread
%% ========================================================================
for s = 1:length(CCIDList)
  
  CCID = CCIDList{s};
  
  for r = 1:length(ROINames)
    
    fN = sprintf('data/%s/MVB_%s_con3_Hard-Easy_model-%s.mat',CCID,ROINames{r},model);
    load(fN,'MVB');
    spread(s,r) = getMVBWeights(MVB);
    
  end
end
spread_LH = spread(:,1);
spread_RH = spread(:,2);
spread_Bi = spread(:,3);
violinplot(spread)


%% Boost Analysis
%% Assign each subject as boost/equivalent/reduction
%% ========================================================================
ordy = [];
for s = 1:length(CCIDList)
  CCID = CCIDList{s};
  
  fN = sprintf('data/%s/MVB_%s_con3_Hard-Easy_model-%s.mat',CCID,ROINames{1},model);
  load(fN,'MVB');
  F_L(s) = max(MVB.M.F(2:end) - MVB.M.F(1));
  
  fN = sprintf('data/%s/MVB_%s_con3_Hard-Easy_model-%s.mat',CCID,ROINames{3},model);
  load(fN,'MVB');
  F_Bi(s) = max(MVB.M.F(2:end) - MVB.M.F(1));
  
  F_diff(s) = F_Bi(s) - F_L(s);
  
  %Boost > equiv > reduction
  if F_diff(s) > 3
    ordy(s) = 2; % > 3: 2
  elseif F_diff(s) < -3
    ordy(s) = 0; % < -3: 0
  else
    ordy(s) = 1;  % between -3 and 3: 1
  end
end
ordy = ordy';

d = table(CCIDList,T.Age, ...
groupFvals,idx_couldNotDecode, ...
spread_LH,spread_RH,spread_Bi, ...
ordy, ...
T.GenderNum,T.handedness);

d.Properties.VariableNames = {'CCID','age','groupFvals','idx_couldNotDecode',...
  'spread_LH','spread_RH','spread_Bi',...
  'ordy',...
  'GenderNum','handedness'};



%Get stats for MVB decoding (before we exclude those who fail):
groupFvals = d.groupFvals;
% mean(groupFvals) ; median(groupFvals)
[H,P,CI,STATS] = ttest(groupFvals,3,'tail','right')
% [P,H] = signtest(groupFvals,3,'alpha',0.05,'tail','right') %Non-parametric
% figure('Position',[10 10 900 600]),hist(groupFvals,30);
extrad = table(d.age,d.groupFvals); extrad.Properties.VariableNames = {'age','Log'};
writetable(extrad,fullfile(RDir,'extradata_ShuffledGroupFVals.csv'));


%Who has failed MVB decoding (bilateral model)?
if flag_dropMVBSubjects
  idx = logical(d.idx_couldNotDecode);
  fprintf('\n%d dropped for failed decoding\n', sum(idx));
  d(idx,:) = [];
end


%% Write csv for R analysis
%% ========================================================================
writetable(d,fullfile(RDir,'data.csv'));

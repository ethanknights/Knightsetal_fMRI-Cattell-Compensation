function camcan_main_mvb_top(roiNames,conditionName,con,CCIDList,model)

%% Purpose: MVB analysis for CamCAN Compensation project
%
% Top script for running MVB:
% Uses voxel features from ROImask.nii to decode contrast (con images)
%
% loops through subjects doing single ROIs then combine analysis
%
%
% calls camcan_main_mvb_LOOmask_ui
% calls camcan_main_mvb_LOOmask_combine_ui.m
%
% Input
%=======
% roiNames:
%   1 x 2 cell array of strings for the 2 single roi masks.
%   Don't include '.nii' suffix and ensure file is located within mvbDir
%
% conditionName:
%   String of condition name (just for output filenames)
%
% con:
%   1 x 1 value (double) that matches the con image number for decoding
%   (e.g. for con_0001.nii, con = 1). Adapt code if > 9 (double digits)
%
% CCIDList:
%   nSubs x 1 cell array of subject names (i.e. directory names)
%
% model:
%   String for spatial priors: 'sparse' | 'smooth'
%
%
% Output
%=======
% MVB structure/.jpg stored in
% <betaDir>/<sub>/MVB_<ROI>_con<con>_<conditionName>.mat
%
% Changes
%========
% AM Nov 2016
% and Sept 2017
% tidied March 2018
% adapted for HAROLD study EK 2020
% modified to skip LOO mask creation EK Jan 2021


%-- Setup paths / variables --%
mvbDir = '/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/MVB';
if any(ismember(regexp(path,pathsep,'Split'),mvbDir)); else; addpath(mvbDir); end

qSPM

betaDir = 'data';

nSubs = length(CCIDList);

%get nVox in rois
nVoxList = [];
for r = 1:2
  [y] = spm_read_vols(spm_vol([roiNames{r},'.nii']));
  nVoxList(r) = length(find(y));
  fprintf('nVox for ROI %d %s: %d\n',r, [roiNames{r},'.nii'], nVoxList(r));
end


%----- MVB -----%
fprintf('Starting camcan_main_mvb_top.m\n')
for s=1:nSubs
  
  %- Reset -%
  allXYZmm = [];
  cd(mvbDir)
  
  CCID = CCIDList{s};
  fprintf('Processing: %s %s\n',s,CCID)
  
  wkdir = fullfile(mvbDir,betaDir,CCID);
  cd(wkdir);
  load('SPM.mat','SPM');
  
  %- Fix paths within SPM.mat (needed if data was not created here or moved) -%
  SPM.swd = pwd;
  assert(logical(exist(SPM.xY.VY(1).fname,'file')),'missing file:%s',SPM.xY.VY(1).fname)
   
  %-- L ROI, then R ROI --%
  for region=1:length(roiNames)
    
    MVB = [];
    roiPath = [];
    
    %- Specify ROI fN for output -%
    roinam = roiNames{region};
    nvox = nVoxList(region);
    fName = sprintf('MVB_%s_con%s_%s_model-%s', roinam,num2str(con),conditionName,model);
    
    %- Load XYZmm from makeXYZmm.m -%
    selXYZmm{region} = load([CCID,'_',roinam,'.mat'],'selXYZmm');
    
    %- Do MVB -%
    try
      load(fName,'MVB')
    catch
      [MVB] = camcan_main_mvb_ui(SPM,con,model,fName,selXYZmm{region}.selXYZmm);
    end
    
    %-Store two ROIs for combine script-%
    allMVB{region}=MVB;
    
  end
  
  %-- Combine L & R --%
  MVB = [];
  roiPath = [];
  
  %- Specify ROI fN for output -%
  roinam = [roiNames{1},'&',roiNames{2}];
  fName = sprintf('MVB_%s_con%s_%s_model-%s',roinam,num2str(con),conditionName,model)
  
  %- Load XYZmm from makeXYZmm.m -%
  selXYZmm{region} = load([CCID,'_',roinam,'.mat'],'selXYZmm');
  
  try
    load(fName,'MVB')
    allMVB{3} = MVB;
  catch
    allMVB{3} = camcan_main_mvb_ui(SPM,con,model,fName,selXYZmm{region}.selXYZmm);
  end
  
  %-- Establish successful MVB decoding --%
  
  getPFor = 3; %CHOOSE ONE %Left,Right,Bilateral
  
  MVB = allMVB{getPFor};
  
  %-specify output filename-%
  if getPFor == 3
    roinam = [roiNames{1},'&',roiNames{2}]; %Joint model
  else
    roinam = roiNames{getPFor}; %Single ROI model
  end
  fName = sprintf('MVB_%s_con%s_%s_model-%s', roinam,num2str(con),conditionName,model);
  
  
  try
    p = MVB.p_value;
  catch  %permutation p has not been saved
    
    %real model
    F = max(MVB.M.F(2:end) - MVB.M.F(1)); %this was diff in parpool_p originally, but made identical now
    
    %phase-shuffled model
    [p, F0, MVB1] = camcan_mvb_parpool_p(MVB,20); %spm_phase_shuffle the timeseries
    Fvals = F - mean(F0); %20 null, 1 real, subtract mean(null) from real per sub
    
    MVB.p_value = p;
    MVB.F0 = F0;
    MVB.Fvals = Fvals;
    save(fName, 'MVB')
    
  end
  
end

cd(mvbDir)

end



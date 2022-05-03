%==========================================================================
%% Dir Setup - Do Once
%% You'll need to update the hard paths to the masks, SPMs & demographic table!
%==========================================================================

clear

%-subInfo-%
!cp -f /imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/T_withROIs.csv ./

%-ROIs-%
!cp -f /imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/results/glm_dvCattellcont_iv1_n223_nPerm1000/MVB_thresholdedMap_t5000.nii TaskMap.nii
!cp -f /imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/masks/Fig_ROIs/4ROIs/mask-cluster_con-intersectAgeBhv_ROI-PCu.nii compensationROI.nii


%% SPM betas (Taken from PPI - fix the SPM paths) - 
%% ========================================================================
destDir_root = 'data'; mkdir(destDir_root);

%% Load KT's original table from project root Dir for subject sprcific information e.g. age, gender, filepaths to imaging data 
path2data = '/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc';
T = readtable(fullfile(path2data,'T_ccc_ethan.xlsx'));
nSubs = height(T);


%% Copy once
cd(destDir_root)
!cp /imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/firstlevel/* ./ -r
cd ../
%% Ensure all SPM's exists!
for s = 1:nSubs; CCID = T.SubCCIDc{s};
  fN_SPM = fullfile(destDir_root,CCID,'SPM.mat');
  assert(logical(exist(fN_SPM,'file')));
end


%% Fix paths (SPM Volume filenames are fixed in main SPM analysis)
%RP
T.f_rp = regexprep(T.f_rp,'/home/sw932/Cattell_analysis/cattell_data/rawdata/','/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/data/processed/');
for s = 1:nSubs; assert(logical(exist(T.f_rp{s},'file'))); end
%WM
for s = 1:nSubs
  tmpD = dir(fullfile(path2data,'data','processed','Session*',T.SubCCIDc{s},'wm','ROI_epi.mat'));  assert(length(tmpD) == 1,T.SubCCIDc{s})
  T.f_wm{s} = fullfile(tmpD.folder,tmpD.name);
end
%CSF
for s = 1:nSubs
  tmpD = dir(fullfile(path2data,'data','processed','Session*',T.SubCCIDc{s},'csf','ROI_epi.mat'));  assert(length(tmpD) == 1,T.SubCCIDc{s})
  T.f_csf{s} = fullfile(tmpD.folder,tmpD.name);
end
%SPM.swd + volume paths
for s = 1:nSubs; CCID = T.SubCCIDc{s};
  
  %load SPM
  fN_SPM = fullfile(destDir_root,CCID,'SPM.mat');
  load(fN_SPM);
  
  %SPM.swd
  SPM.swd = fullfile(pwd,destDir_root,CCID,'spm'); %swd (avoid overwrite)
  %SPM.xY.P
  SPM.xY.P = strvcat(regexprep(cellstr(SPM.xY.P),'/home/sw932/Cattell_analysis/cattell_data/rawdata/','/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/data/processed/'));
  %SPM.xY.VY (!should just be:   setfield(SPM.xY.VY,'fname',tmp) 
  tmp = regexprep(cellstr({SPM.xY.VY.fname}'),'/home/sw932/Cattell_analysis/cattell_data/rawdata/','/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/data/processed/');
  for i = 1:length(tmp);
    SPM.xY.VY(i).fname = tmp{i};
  end
  %save
  save(fN_SPM,'SPM')
  
  % add to table
  T.f_firstlevel{s} = fullfile(path2data,'PPI',fN_SPM);
end
%Unnecessary but con_001.nii for completion:
T.f_Cattellcont = regexprep(T.f_Cattellcont,'/home/sw932/Cattell_analysis/cattell_data/','/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/');


%% write updated table
writetable(T,'subInfo.csv');

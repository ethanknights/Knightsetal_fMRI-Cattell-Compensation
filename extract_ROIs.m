%% Extract ROIs
%% ------------------------------------------------------------------------

path2data = '/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc'; 
load(fullfile(path2data,'T_settings_sw20210622.mat'));
T.f_Cattellcont = regexprep(T.f_Cattellcont,'/home/sw932/Cattell_analysis/cattell_data/','/imaging/camcan/sandbox/kt03/projects/collabs/ethanK/ccc/');


VOI = table();
%rMFG
roifN = fullfile(path2data,'masks','Fig_ROIs','4ROIs','mask-cluster_con-intersectAgeBhv_ROI-rMFG.nii');
[tmpD] = extract_VOI(roifN,T.f_Cattellcont);
VOI.rMFG = tmpD';
%lSPOC
roifN = fullfile(path2data,'masks','Fig_ROIs','4ROIs','mask-cluster_con-intersectAgeBhv_ROI-PCu.nii');
[tmpD] = extract_VOI(roifN,T.f_Cattellcont);
VOI.lSPOC = tmpD';
%angCing
roifN = fullfile(path2data,'masks','Fig_ROIs','4ROIs','mask-cluster_con-intersectAgeBhv_ROI-extra_antCing.nii');
[tmpD] = extract_VOI(roifN,T.f_Cattellcont);
VOI.antCing = tmpD';
%lPFC
roifN = fullfile(path2data,'masks','Fig_ROIs','4ROIs','mask-cluster_con-intersectAgeBhv_ROI-extra_lPFC.nii');
[tmpD] = extract_VOI(roifN,T.f_Cattellcont);
VOI.lPFC = tmpD';
%frontalANDCing
roifN = fullfile(path2data,'masks','Fig_ROIs','4ROIs','mask-cluster_con-intersectAgeBhv_ROI-frontalANDCing.nii');
[tmpD] = extract_VOI(roifN,T.f_Cattellcont);
VOI.frontal = tmpD';



% %% multiple Regression with KT function
% %% ------------------------------------------------------------------------
% Ttemp    = [T VOI];
% namevoi = VOI.Properties.VariableNames;
% 
% for ivoi = 1:numel(namevoi)
%     model   = namevoi{ivoi};
%     model   = [model '~PC6*Age+GenderNum+handedness'];
%     varnames = strsplit(model,{'~','+','*'});
%     tbl     = Ttemp(:,varnames);
%     %tbl     = normalize(tbl);
%     tbl.PC6 = normalize(tbl.PC6);
%     tbl.Age = normalize(tbl.Age);
%     tbl.GenderNum = normalize(tbl.GenderNum);
%     tbl.handedness = normalize(tbl.handedness);
%     mlr     = fitlm(tbl,model); %mlr = fitlm(tbl,model,'RobustOpts',1);
%     
%     
%     % Visualisation of interaction
%     labels      = [];
%     labels.Y    = namevoi{ivoi};
%     labels.X    = 'PC6'; % 'ASL' 'Performance'
%     labels.Z    = 'Age';
%     labels.zH   = 'Old';
%     labels.zM   = 'Mid';
%     labels.zL   = 'Young';
%     cfg         = [];
%     cfg.tbl     = tbl;
%     cfg.labels  = labels;
%     cfg.model   = model;
%     %kat_plotting_interaction_2way(cfg);
%     kat_plotting_interaction_2way_ek(cfg);
% end

%% look at ROI
% addpath /imaging/henson/users/ek03/toolbox/BrainNetViewer_20191031
% BrainNet

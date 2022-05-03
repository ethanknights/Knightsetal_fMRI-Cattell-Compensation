mkdir('masks'); cd('masks')
% setenv FSLDIR /imaging/local/software/fsl/v6.0.1/centos7
% source ${FSLDIR}/etc/fslconf/fsl.csh
% set path = (${FSLDIR}/bin $path)


%% Age - generate binary cluster map
system('cluster -i results/glm_dvCattellcont_ivPC6Age_n223_nPerm2000/tval_Age_tfce197.nii -t 0.01 -o clusterIndex'); !gunzip --force clusterIndex.nii.gz
system('fslmaths clusterIndex -bin clusterIndex'); !gunzip --force clusterIndex.nii.gz
!mv --force clusterIndex.nii masks/mask-cluster_con-agePos.nii
%% view tfce map + mask
%    !fsleyes results/glm_dvCattellcont_ivPC6Age_n223_nPerm2000/tval_Age_tfce197.nii masks/mask-cluster_con-agePos.nii

%% Bhv - generate binary cluster map
system('cluster -i results/glm_dvCattellcont_ivPC6Age_n223_nPerm2000/tval_PC6_tfce197.nii -t 0.01 -o clusterIndex'); !gunzip --force clusterIndex.nii.gz
system('fslmaths clusterIndex -bin clusterIndex'); !gunzip --force clusterIndex.nii.gz
!mv --force clusterIndex.nii masks/mask-cluster_con-bhvPos.nii
%% view tfce map + mask
%    !fsleyes results/glm_dvCattellcont_ivPC6Age_n223_nPerm2000/tval_PC6_tfce197.nii masks/mask-cluster_con-bhvPos.nii

%% Age + Bhv Intersect mask
system('fslmaths masks/mask-cluster_con-agePos.nii -mas masks/mask-cluster_con-bhvPos.nii mask-intersect.nii.gz')

%% manually edited intersect-mask.nii (mricro) to separate into 2 individual masks:
%masks/mask-cluster_con-intersectAgeBhv_ROI-lSPOC.nii
%masks/mask-cluster_con-intersectAgeBhv_ROI-rMFG.nii
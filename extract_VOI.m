
function [meanActivationVals] = extract_VOI(roifN,conImagefN)

%% roifN = single roi file path
%% conImgfN = cell list of con images (1 per sub)

fprintf('Extracting Mean Activation from ROI:\n', roifN)


for s = 1:length(conImagefN)
  
  %         %SIMPLE ROI EXTRACTION (IGNORES HEADER TRANSFORMATIONS)
  %         %%get roi XYZ coords
  %         Y = spm_read_vols(spm_vol(roifN));
  %         idx = find(Y>0);
  %         [x,y,z] = ind2sub(size(Y),idx);
  %         XYZ = [x y z]';
  %         %get roi timeseries
  %         scanfN = cellstr(spm_select('ExtFPList',sprintf('data/func/%s/',CCID{s}),'swarsub'));
  %         S.d = spm_get_data(spm_vol(scanfN),XYZ);
  %             %write nifti to check
  %             writeNIFTI('myROI.nii',XYZ,'/imaging/ek03/MVB/FreeSelection/pp/data/statsGroupAllBIGBaseline/Mc_L_100vox.nii')
  %             spm_check_registration('myROI.nii','/imaging/ek03/single_subj_T1.nii')
  
  %% get roi timeseries (based on roi_extract.m)
  VY = spm_vol(conImagefN{s});
  Yinv = inv(VY(1).mat); %Get inverse transform (assumes all data files are aligned)
  
  [VM,mXYZmm] = spm_read_vols(spm_vol(roifN));
  
  %Transform ROI XYZ in mm to voxel indices in data:
  yXYZind = Yinv(1:3,1:3)*mXYZmm + repmat(Yinv(1:3,4),1,size(mXYZmm,2));
  
  f = find(VM);
  S.d = spm_get_data(VY,yXYZind(:,f));
          %write nifti to check:
          %writeNIFTI('myROI.nii',yXYZind(:,f),VY(1).fname)
          %spm_check_registration('myROI.nii','/imaging/henson/users/ek03/single_subj_T1.nii')
          %pause
          %check again when stealing a roi file header instead:
%           writeNIFTI('myROI.nii',yXYZind(:,f),conImagefN{s})
%           spm_check_registration('myROI.nii','/imaging/ek03/single_subj_T1.nii')
%           pause
  
  meanActivationVals(s) = nanmean(S.d);

end

end

%% Utils
%% ------------------------------------------------------------------------
function writeNIFTI(ROIoN,coords,templateName)

hdr = spm_vol(templateName);
img = spm_read_vols(hdr);
    
%strip data from template
for i = 1:size(img(:))
    img(i) = 0;
end

%paint coords
nVox = size(coords,2);
for i = 1:nVox
    y = coords(:,i);
    img(y(1),y(2),y(3)) = 1;
end

%rewrite .nii
hdr.fname = ROIoN;
spm_write_vol(hdr,img);
%spm_check_registration('/imaging/ek03/single_subj_T1.nii','myROI.nii','/imaging/ek03/MVB/FreeSelection/pp/data/statsGroupAllBIGBaseline/Mc_L_100vox.nii') 

end

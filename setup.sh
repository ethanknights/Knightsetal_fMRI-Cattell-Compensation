#!/bin/bash
#Use: ./setup.sh     
#Ensure chmod +x setup.sh

echo 'Downloading data from the Open Science Framework for Knights et al. (2022).
OSF Project: Neural Functional Compensation for Fluid Intelligence Cognitive Decline in Healthy Ageing
'

curl -L 'https://osf.io/e3k5g/?action=download&version=1' > OSF_data.zip

echo 'Decompressing data
'
unzip -o OSF_data.zip
rm -f OSF_data.zip

echo 'Moving data to relevant .csv sub-directories
'
#### Univariate
mkdir R/csv
mv univariate.csv R/csv/

#### Univariate (Vascular control)
mkdir R_vascular/csv
mv univariate_vascular_RSFA.csv R_vascular/csv/

#### MVB
# Cuneal Cortex
mkdir MVB/R/dropMVBSubjects-1/70voxel_model-sparse/csv
mv MVB_cuneal.csv  MVB/R/dropMVBSubjects-1/70voxel_model-sparse/csv/

# Frontal cortex
mkdir MVB/R/dropMVBSubjects-1/control-frontalROI_70voxel_model-sparse/csv
mv MVB_frontal.csv MVB/R/dropMVBSubjects-1/control-frontalROI_70voxel_model-sparse/csv

#### MVB (Multivariate mapping)
# Cuneal Cortex
mv MVB_multvariateMapping-Cuneal/extradata_ShuffledGroupFVals.csv MVB/R/dropMVBSubjects-1/70voxel_model-sparse/csv/

# Frontal cortex
mv MVB_multvariateMapping-Frontal/extradata_ShuffledGroupFVals.csv MVB/R/dropMVBSubjects-1/control-frontalROI_70voxel_model-sparse/csv

echo 'Cleaning
'
rmdir MVB_multvariateMapping-Cuneal/
rmdir MVB_multvariateMapping-Frontal/

echo 'Setup complete - ready for R modelling. For analysis instructions see:
https://github.com/ethanknights/Knightsetal_fMRI-Cattell-Compensation

'
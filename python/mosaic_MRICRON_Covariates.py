import gl
gl.resetdefaults()

#open background image
gl.loadimage('spm152')

#open overlay: show positive regions
gl.overlayload('/nii_Covariates/tval_Age_tfce197.nii')
gl.minmax(1, 0, 250)
gl.colorname (1,"2green")

#open overlay: show positive regions
gl.overlayload('nii_Covariates/tval_PC6_tfce197.nii')
gl.minmax(2, 0, 250)
gl.colorname (2,"1red")

#gl.moasic
#-----------------
#L+                     labels on
#first value            slice overlap
#S X R 0                surface cross section with mosaics' slice lines
#gl.mosaic("A H -0.1 -6 0 6 12 18; 24 30 36 42 48")

gl.mosaic("A H -0.1 V -0.1 -8 0 8 16 24; 28 32 40 48 54")


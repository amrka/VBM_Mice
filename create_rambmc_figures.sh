#!/bin/bash

# a simple script to create multislice images overlaying stat images on top of rambmc template

# first transform the stat maps
antsApplyTransforms \
-i '/Volumes/Amr_1TB/VBM/VBM_stats/PALM_VBM_FWHM_3_10000_tfce_tstat_fwep_c1.nii.gz' \
-r '/Volumes/Amr_1TB/VBM/registration/rambmc.nii' \
-t '/Volumes/Amr_1TB/VBM/registration/TMBTA_to_ambmc_Composite.h5' \
-t '/Volumes/Amr_1TB/VBM/registration/VBM_to_TMBTA_Composite.h5' \
-o /Users/amr/Dropbox/thesis/3D/VBM_c1_to_rambmc.nii.gz \
-v


antsApplyTransforms \
-i '/Volumes/Amr_1TB/VBM/VBM_stats/PALM_VBM_FWHM_3_10000_tfce_tstat_fwep_c2.nii.gz' \
-r '/Volumes/Amr_1TB/VBM/registration/rambmc.nii' \
-t '/Volumes/Amr_1TB/VBM/registration/TMBTA_to_ambmc_Composite.h5' \
-t '/Volumes/Amr_1TB/VBM/registration/VBM_to_TMBTA_Composite.h5' \
-o /Users/amr/Dropbox/thesis/3D/VBM_c2_to_rambmc.nii.gz \
-v

# you need to transform the registered images from float64 to float32, otherwise
# fsleyes render will crash
# at the values in stat maps here, there is no difference between the 64 and 32

fslmaths /Users/amr/Dropbox/thesis/3D/VBM_c1_to_rambmc.nii.gz -mul 1 /Users/amr/Dropbox/thesis/3D/VBM_c1_to_rambmc.nii.gz -odt float
fslmaths /Users/amr/Dropbox/thesis/3D/VBM_c2_to_rambmc.nii.gz -mul 1 /Users/amr/Dropbox/thesis/3D/VBM_c2_to_rambmc.nii.gz -odt float
#===================================================================================================
stat_1='/Users/amr/Dropbox/thesis/3D/VBM_c1_to_rambmc.nii.gz'
stat_2='/Users/amr/Dropbox/thesis/3D/VBM_c2_to_rambmc.nii.gz'



dir='/Users/amr/Dropbox/thesis/3D'


fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes' #aliases do not work inside scripts
rambmc='/Users/amr/Dropbox/thesis/registration/rambmc.nii'


for slice_no in {526,500,476,451,425,399,373,347,321,295};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidez    -vl 170 ${slice_no} 124 \
	--hideCursor   --outfile    ${dir}/VBM_render_${slice_no}.png   \
	${rambmc} --displayRange 50 210  \
	${stat_1} --cmap red-yellow     --displayRange 0.95  1 \
	${stat_2} --cmap blue-lightblue --displayRange 0.95  1

	convert  ${dir}/VBM_render_${slice_no}.png -crop 740x480+30+60  ${dir}/VBM_render_cropped_${slice_no}.png

done

pngappend \
${dir}/VBM_render_cropped_295.png + \
${dir}/VBM_render_cropped_321.png + \
${dir}/VBM_render_cropped_347.png + \
${dir}/VBM_render_cropped_373.png + \
${dir}/VBM_render_cropped_399.png - \
${dir}/VBM_render_cropped_425.png + \
${dir}/VBM_render_cropped_451.png + \
${dir}/VBM_render_cropped_476.png + \
${dir}/VBM_render_cropped_500.png + \
${dir}/VBM_render_cropped_526.png  \
${dir}/VBM_FWHM_3_output.png

# remove background
convert ${dir}/VBM_FWHM_3_output.png -transparent black ${dir}/VBM_FWHM_3_output_no_bg.png

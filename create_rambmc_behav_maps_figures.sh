#!/bin/bash

# a simple script to create multislice images overlaying stat images on top of rambmc template

# this for behavior maps,
# we have only a handful of them:
# /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz
# /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz
#
# /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz
# /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz

mkdir /Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig

#1: /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz
stat_map=/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz
stat_map_name=`echo ${stat_map} | sed  s/.*con_// | sed s[.mat/.*[[`;

contrast_no=`echo ${stat_map} | sed  s/.*_c// | sed s[.nii.gz[[`

# first transform the stat maps
antsApplyTransforms \
-i ${stat_map} \
-r '/Volumes/Amr_1TB/VBM/registration/rambmc.nii' \
-t '/Volumes/Amr_1TB/VBM/registration/TMBTA_to_ambmc_Composite.h5' \
-t '/Volumes/Amr_1TB/VBM/registration/VBM_to_TMBTA_Composite.h5' \
-o /Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz \
-v --float
#float64 crashes fsleyes

#=============================================================================================================================================================
dir='/Users/amr/Dropbox/thesis/3D/VBM_Corr/behav_fig'

#aliases do not work inside scripts
fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes'
rambmc='/Users/amr/Dropbox/thesis/registration/rambmc.nii'


for slice_no in {526,500,476,451,425,394,373,347,321,295};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidez    -vl 170 ${slice_no} 124 \
	--hideCursor   --outfile    ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png   \
	${rambmc} --displayRange 50 210  \
	/Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz --cmap red-yellow     --displayRange 0.95  1

	convert  ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png -crop 740x480+30+60  ${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_${slice_no}.png

done

pngappend \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_295.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_321.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_347.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_373.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_394.png - \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_425.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_451.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_476.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_500.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_526.png  \
${dir}/${stat_map_name}_c${contrast_no}_output.png

# remove background
convert ${dir}/${stat_map_name}_c${contrast_no}_output.png -transparent black ${dir}/${stat_map_name}_c${contrast_no}_output_no_bg.png

#=============================================================================================================================================================
#=============================================================================================================================================================
#=============================================================================================================================================================
#=============================================================================================================================================================
#2: /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz

stat_map=/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz
stat_map_name=`echo ${stat_map} | sed  s/.*con_// | sed s[.mat/.*[[`;

contrast_no=`echo ${stat_map} | sed  s/.*_c// | sed s[.nii.gz[[`

# first transform the stat maps
antsApplyTransforms \
-i ${stat_map} \
-r '/Volumes/Amr_1TB/VBM/registration/rambmc.nii' \
-t '/Volumes/Amr_1TB/VBM/registration/TMBTA_to_ambmc_Composite.h5' \
-t '/Volumes/Amr_1TB/VBM/registration/VBM_to_TMBTA_Composite.h5' \
-o /Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz \
-v --float
#float64 crashes fsleyes

#===================================================================================================
dir='/Users/amr/Dropbox/thesis/3D/VBM_Corr/behav_fig'

#aliases do not work inside scripts
fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes'
rambmc='/Users/amr/Dropbox/thesis/registration/rambmc.nii'


for slice_no in {526,500,476,451,425,394,373,347,321,295};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidez    -vl 170 ${slice_no} 124 \
	--hideCursor   --outfile    ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png   \
	${rambmc} --displayRange 50 210  \
	/Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz --cmap blue-lightblue     --displayRange 0.95  1

	convert  ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png -crop 740x480+30+60  ${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_${slice_no}.png

done

pngappend \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_295.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_321.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_347.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_373.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_394.png - \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_425.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_451.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_476.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_500.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_526.png  \
${dir}/${stat_map_name}_c${contrast_no}_output.png

# remove background
convert ${dir}/${stat_map_name}_c${contrast_no}_output.png -transparent black ${dir}/${stat_map_name}_c${contrast_no}_output_no_bg.png

#=============================================================================================================================================================
#=============================================================================================================================================================
#=============================================================================================================================================================
#=============================================================================================================================================================
#3: /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz
stat_map=/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz
stat_map_name=`echo ${stat_map} | sed  s/.*con_// | sed s[.mat/.*[[`;

contrast_no=`echo ${stat_map} | sed  s/.*_c// | sed s[.nii.gz[[`

# first transform the stat maps
antsApplyTransforms \
-i ${stat_map} \
-r '/Volumes/Amr_1TB/VBM/registration/rambmc.nii' \
-t '/Volumes/Amr_1TB/VBM/registration/TMBTA_to_ambmc_Composite.h5' \
-t '/Volumes/Amr_1TB/VBM/registration/VBM_to_TMBTA_Composite.h5' \
-o /Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz \
-v --float
#float64 crashes fsleyes

#=============================================================================================================================================================
dir='/Users/amr/Dropbox/thesis/3D/VBM_Corr/behav_fig'

#aliases do not work inside scripts
fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes'
rambmc='/Users/amr/Dropbox/thesis/registration/rambmc.nii'


for slice_no in {526,500,476,451,425,394,373,347,321,295};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidez    -vl 170 ${slice_no} 124 \
	--hideCursor   --outfile    ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png   \
	${rambmc} --displayRange 50 210  \
	/Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz --cmap red-yellow     --displayRange 0.95  1

	convert  ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png -crop 740x480+30+60  ${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_${slice_no}.png

done

pngappend \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_295.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_321.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_347.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_373.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_394.png - \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_425.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_451.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_476.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_500.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_526.png  \
${dir}/${stat_map_name}_c${contrast_no}_output.png

# remove background
convert ${dir}/${stat_map_name}_c${contrast_no}_output.png -transparent black ${dir}/${stat_map_name}_c${contrast_no}_output_no_bg.png

#=============================================================================================================================================================
#=============================================================================================================================================================
#=============================================================================================================================================================
#=============================================================================================================================================================
#4: /Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz

stat_map=/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz
stat_map_name=`echo ${stat_map} | sed  s/.*con_// | sed s[.mat/.*[[`;

contrast_no=`echo ${stat_map} | sed  s/.*_c// | sed s[.nii.gz[[`

# first transform the stat maps
antsApplyTransforms \
-i ${stat_map} \
-r '/Volumes/Amr_1TB/VBM/registration/rambmc.nii' \
-t '/Volumes/Amr_1TB/VBM/registration/TMBTA_to_ambmc_Composite.h5' \
-t '/Volumes/Amr_1TB/VBM/registration/VBM_to_TMBTA_Composite.h5' \
-o /Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz \
-v --float
#float64 crashes fsleyes

#===================================================================================================
dir='/Users/amr/Dropbox/thesis/3D/VBM_Corr/behav_fig'

#aliases do not work inside scripts
fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes'
rambmc='/Users/amr/Dropbox/thesis/registration/rambmc.nii'


for slice_no in {526,500,476,451,425,394,373,347,321,295};do

	${fsleyes} render  \
	--scene ortho -no   --displaySpace world --hidex --hidez    -vl 170 ${slice_no} 124 \
	--hideCursor   --outfile    ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png   \
	${rambmc} --displayRange 50 210  \
	/Users/amr/Dropbox/thesis/3D/VBM_corr/behav_fig/${stat_map_name}_rambmc_c${contrast_no}.nii.gz --cmap blue-lightblue     --displayRange 0.95  1

	convert  ${dir}/VBM_${stat_map_name}_c${contrast_no}_${slice_no}.png -crop 740x480+30+60  ${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_${slice_no}.png

done

pngappend \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_295.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_321.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_347.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_373.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_394.png - \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_425.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_451.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_476.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_500.png + \
${dir}/VBM_${stat_map_name}_c${contrast_no}_cropped_526.png  \
${dir}/${stat_map_name}_c${contrast_no}_output.png

# remove background
convert ${dir}/${stat_map_name}_c${contrast_no}_output.png -transparent black ${dir}/${stat_map_name}_c${contrast_no}_output_no_bg.png

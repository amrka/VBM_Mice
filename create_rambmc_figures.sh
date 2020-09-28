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

#=========================================================================================================
# transfer correlation maps of VBM
mkdir -p /media/amr/Amr_4TB/Dropbox/thesis/3D/VBM_corr/{EPM_open_to_close_ratio.con_EPM_open_to_close_ratio.mat,EPM_time_in_center.con_EPM_time_in_center.mat,EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat,EPM_time_in_closed_arms.con_EPM_time_in_closed_arms.mat,EPM_time_in_closed_arms_percent.con_EPM_time_in_closed_arms_percent.mat,EPM_time_in_opened_arms.con_EPM_time_in_opened_arms.mat,EPM_time_in_opened_arms_percent.con_EPM_time_in_opened_arms_percent.mat,EPM_total_distance.con_EPM_total_distance.mat,EPM_velocity.con_EPM_velocity.mat,OF_center_corners_ratio.con_OF_center_corners_ratio.mat,OF_percent_in_center.con_OF_percent_in_center.mat,OF_percent_in_corners.con_OF_percent_in_corners.mat,OF_sec_in_center.con_OF_sec_in_center.mat,OF_total_distance.con_OF_total_distance.mat,OF_total_time_in_corners.con_OF_total_time_in_corners.mat,OF_velocity.con_OF_velocity.mat}

cd /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_correlation_analysis_outputdir/P_value1/VBM_stats


# # run this on linux, because mac's shell does not read ${img: -12:-7}
for img in */*.nii.gz;do
	thresh=`fslstats $img -p 100`;
	if [[ $thresh > 0.949 ]]; then
		echo "$img -> $thresh";
		behav_dir=`dirname $img`;
		imcp $img  /media/amr/Amr_4TB/Dropbox/thesis/3D/VBM_corr/${behav_dir}/
		imcp \
		/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_correlation_analysis_outputdir/corr_coef_r1/VBM_stats/${behav_dir}/corr_coef_r1.nii.gz \
		/media/amr/Amr_4TB/Dropbox/thesis/3D/VBM_corr/${behav_dir}/
	fi;
done


cd /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_correlation_analysis_outputdir/P_value2/VBM_stats


for img in */*.nii.gz;do
	thresh=`fslstats $img -p 100`;
	if [[ $thresh > 0.949 ]]; then
		echo "$img -> $thresh";
		behav_dir=`dirname $img`;
		imcp $img  /media/amr/Amr_4TB/Dropbox/thesis/3D/VBM_corr/${behav_dir}/
		imcp \
		/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_correlation_analysis_outputdir/corr_coef_r2/VBM_stats/${behav_dir}/corr_coef_r2.nii.gz \
		/media/amr/Amr_4TB/Dropbox/thesis/3D/VBM_corr/${behav_dir}/
	fi;
done

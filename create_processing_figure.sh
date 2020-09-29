#!/bin/bash

# make a directory
mkdir /Users/amr/Dropbox/thesis/3D/processing_fig

# copy necessary files
imcp /media/amr/Amr_4TB/Work/October_Acquistion/Data/261/3D.nii  \
/Users/amr/Dropbox/thesis/3D/processing_fig

imcp /Volumes/Amr_1TB/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_261/Bias_Field_Correction/3D_corrected.nii \
/Users/amr/Dropbox/thesis/3D/processing_fig

imcp /Volumes/Amr_1TB/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_261/Brain_Extraction/highres001_BrainExtractionBrain.nii.gz \
/Users/amr/Dropbox/thesis/3D/processing_fig

imcp /Volumes/Amr_1TB/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_261/Atropos/POSTERIOR_02.nii.gz \
/Users/amr/Dropbox/thesis/3D/processing_fig

imcp /Volumes/Amr_1TB/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_261/Calculate_Jacobian_Determinant/Jacobian.nii.gz \
/Users/amr/Dropbox/thesis/3D/processing_fig

imcp /Volumes/Amr_1TB/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_261/Modulate_GM/Modulated_GM.nii.gz \
/Users/amr/Dropbox/thesis/3D/processing_fig

imcp /Volumes/Amr_1TB/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_261/_fwhm_3/Smoothing/Modulated_GM_smooth.nii.gz \
/Users/amr/Dropbox/thesis/3D/processing_fig



cd /Users/amr/Dropbox/thesis/3D/processing_fig

fsleyes='pythonw /Users/amr/anaconda3/bin/fsleyes'

for img in *.ni*;do

	img_name=`remove_ext $img`

	for slice_no in {130,104,78,52,26};do

		${fsleyes} render  \
		--scene ortho -no   --displaySpace world --hidex --hidez  --hideLabels  -vl 54 ${slice_no} 39 \
		--hideCursor   --outfile    ${img_name}_${slice_no}.png   $img 
		
	done

	pngappend \
	${img_name}_26.png + 0 \
	${img_name}_52.png + 0 \
	${img_name}_78.png + 0 \
	${img_name}_104.png + 0 \
	${img_name}_130.png  \
	${img_name}_output.png

	# remove background
	convert ${img_name}_output.png -transparent black ${img_name}_output_no_bg.png

done


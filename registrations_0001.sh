#!/bin/bash


cd /media/amr/Amr_4TB/Work/October_Acquistion/VBM/registration

#Augment the turone template to match the study template
#I choose turone template beachsue it is a mixture of ambmc and allen. moreover, it has tissue priors and an atlas
Augment.sh TMBTA_Brain_Template.nii 10

fslorient -deleteorient TMBTA_Brain_Template.nii
fslorient -setsformcode 1 TMBTA_Brain_Template.nii
fslorient -setqformcode 1 TMBTA_Brain_Template.nii

antsRegistrationSyN.sh \
-d 3 \
-m VBM_template_manual_ext.nii.gz \
-f TMBTA_Brain_Template.nii \
-n 16 \
-o VBM_to_TMBTA_


#now we back-register the TMBTA priors to our template space
antsApplyTransforms \
-d 3 \
-i TMBTA_Grey.nii \
-r VBM_template_manual_ext.nii.gz \
-o GM_to_VBM.nii.gz \
-t VBM_to_TMBTA_InverseComposite.h5 \
-v

antsApplyTransforms \
-d 3 \
-i TMBTA_White.nii \
-r VBM_template_manual_ext.nii.gz \
-o WM_to_VBM.nii.gz \
-t VBM_to_TMBTA_InverseComposite.h5 \
-v

antsApplyTransforms \
-d 3 \
-i TMBTA_CSF.nii \
-r VBM_template_manual_ext.nii.gz \
-o CSF_to_VBM.nii.gz \
-t VBM_to_TMBTA_InverseComposite.h5 \
-v


#---------------------------------------------------------------------------------------------------------------------
# Move the atlas as well

# /media/amr/Amr_4TB/Turone_Mouse_Brain_Template/Turone_Mouse_Brain_Atlas/TMBTA_Brain_Atlas.nii
# /media/amr/Amr_4TB/Turone_Mouse_Brain_Template/Turone_Mouse_Brain_Atlas/TMBTA_ItK_Label_File.txt
# /media/amr/Amr_4TB/Turone_Mouse_Brain_Template/Turone_Mouse_Brain_Atlas/TMBTA_ListofStructures.xlsx
# /media/amr/Amr_4TB/Turone_Mouse_Brain_Template/Turone_Mouse_Brain_Atlas/TMBTA_RGB_Label_File.xls


cp /media/amr/Amr_4TB/Turone_Mouse_Brain_Template/Turone_Mouse_Brain_Atlas/* \
/media/amr/Amr_4TB/Work/October_Acquistion/VBM/registration

cd /media/amr/Amr_4TB/Work/October_Acquistion/VBM/registration

Augment.sh TMBTA_Brain_Atlas.nii 10

fslorient -deleteorient TMBTA_Brain_Atlas.nii
fslorient -setsformcode 1 TMBTA_Brain_Atlas.nii
fslorient -setqformcode 1 TMBTA_Brain_Atlas.nii

# Move to the VBM_template space

antsApplyTransforms \
-d 3 \
-i TMBTA_Brain_Atlas.nii \
-r VBM_template_manual_ext.nii.gz \
-o Atlas_to_VBM.nii.gz \
-t VBM_to_TMBTA_InverseComposite.h5 \
-n NearestNeighbor \
-v

#-----------------------------------------------------------------------------------------------------------------------
# To iprove the visualization even more, I downsized teh ambmc model to 0.3 after augmentation
# and registered TMBTA to it

antsRegistrationSyN.sh -d 3 \
-m /home/in/aeed/turone/TMBTA_Brain_Template.nii \
-f /home/in/aeed/turone/rambmc.nii \
-n 24 \
-o /home/in/aeed/turone/TMBTA_to_ambmc_

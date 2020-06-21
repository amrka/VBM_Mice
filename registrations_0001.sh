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

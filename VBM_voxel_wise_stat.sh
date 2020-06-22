!#/bin/bash

#Now, we have 16 vs 16
#I tried eliminate 271,272 -> results were the same, but not as symmetric. So, I put them again

#1 copy the files to an appropriate folder
mkdir /home/in/aeed/Work/October_Acquistion/VBM/VBM_stats

#2 copy the fwhm 3 to the folder

cd ~/Work/October_Acquistion/Data

for folder in *;do
    cp ~/Work/October_Acquistion/VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_${folder}/_fwhm_3/Smoothing/Modulated_GM_smooth.nii.gz \
    ~/Work/October_Acquistion/VBM/VBM_stats/${folder}_smooth_3_mod_GM.nii.gz;
done

#3 change the file names to contain group

python ~/SCRIPTS/change_files_to_contain_gp_name.py \
/home/in/aeed/Work/October_Acquistion/VBM/VBM_stats 0 3

#4 merge
fslmerge \
-t \
/home/in/aeed/Work/October_Acquistion/VBM/VBM_stats/VBM_FWHM_3_mod_GM.nii.gz \
/home/in/aeed/Work/October_Acquistion/VBM/VBM_stats/*.nii.gz

#5 create the stat design
design_ttest2 /home/in/aeed/Work/October_Acquistion/VBM/VBM_stats/design_VBM 16 16

#6 run randomise
cd design_ttest2 /home/in/aeed/Work/October_Acquistion/VBM/VBM_stats/design_VBM 16 16

randomise_parallel \
-i VBM_FWHM_3_mod_GM.nii.gz \
-o VBM_FWHM_3 \
-m /home/in/aeed/Work/October_Acquistion/VBM/registration/VBM_template_manual_ext_mask.nii.gz  \
-d design_VBM.mat -t design_VBM.con \
-n 10000 -x --uncorrp -T -V;

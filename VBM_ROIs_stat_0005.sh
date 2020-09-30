#!/bin/bash

#delete if exists
rm -r  /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs
mkdir /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs

cd /media/amr/Amr_4TB/Work/October_Acquistion/Data

for folder in *;do
    cp /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_labels_volumes_workingdir_preproc/VBM_labels_volumes_workflow/_subject_id_${folder}/get_volume_mm3/volumes_in_mm3.csv \
    /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs/${folder}_volumes_in_mm3.csv;
done


python /media/amr/Amr_4TB/Dropbox/SCRIPTS/change_files_to_contain_gp_name.py \
/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs/ 0 3

#python commands to merge in one csv file
cat << EOF > pyscript.py

#Python code to merge all the ROIs from all the subjects
import pandas as pd
import glob

dfs = sorted(glob.glob('/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs/*_volumes_in_mm3.csv', ))
result = pd.concat([pd.read_csv(df) for df in dfs], sort=False) # to prevent the pd from sorting the columns
#replace nan values with zeros
# NaN was the reason behind lines contain less columns in palm

result = result.fillna(0)

# one with header to recognize the results
result.to_csv('/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs/merge_volumes_header.csv', header=True, index=False)

# another one without header for palm
result.to_csv('/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs/merge_volumes_for_palm.csv', header=False, index=False)


EOF

chmod 755 pyscript.py

./pyscript.py

palm \
-i /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/ROIs/merge_volumes_for_palm.csv \
-d /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/design_VBM.mat \
-t /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/design_VBM.con \
-o /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_stats/results_volumes \
-corrcon -fdr -save1-p -twotail


from nipype import config
cfg = dict(execution={'remove_unnecessary_outputs': False})
config.update_config(cfg)


#-----------------------------------------------------------------------------------------------------
# In[1]:
import nipype.interfaces.fsl as fsl
import nipype.interfaces.afni as afni
import nipype.interfaces.ants as ants
import nipype.interfaces.spm as spm

import nibabel as nb

from nipype.interfaces.utility import IdentityInterface, Function
from os.path import join as opj
from nipype.interfaces.io import SelectFiles, DataSink
from nipype.pipeline.engine import Workflow, Node, MapNode, utils
import nipype.interfaces.utility as utility


import numpy as np
import matplotlib.pyplot as plt
from nipype.interfaces.matlab import MatlabCommand
MatlabCommand.set_default_paths('/media/amr/HDD/Sofwares/spm12/')
MatlabCommand.set_default_matlab_cmd("matlab -nodesktop -nosplash")


import subprocess
#-----------------------------------------------------------------------------------------------------
# In[1]:
experiment_dir = '/media/amr/Amr_4TB/Work/October_Acquistion/'

subject_list = ['229', '230', '232', '233', '234',
                '235', '236', '237', '242', '243',
                '244', '245', '252', '253', '255',
                '261', '262', '263', '264', '271',
                '272', '273', '274', '281', '282',
                '286', '287', '362', '363', '364',
                '365', '366']

# subject_list = ['229']

output_dir  = 'VBM/VBM_labels_volumes_output_preproc'
working_dir = 'VBM/VBM_labels_volumes_workingdir_preproc'

VBM_labels_volumes_workflow = Workflow (name = 'VBM_labels_volumes_workflow')
VBM_labels_volumes_workflow.base_dir = opj(experiment_dir, working_dir)

#-----------------------------------------------------------------------------------------------------
# In[1]:
infosource = Node(IdentityInterface(fields=['subject_id']),
                  name="infosource")
infosource.iterables = [('subject_id', subject_list)]

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Images are already augmented
templates = {
 '3d_brain_ex'        : 'VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_{subject_id}/Brain_Extraction/highres001_BrainExtractionBrain.nii.gz',
 'inverse_transfroms' : 'VBM/VBM_workingdir_preproc/VBM_workflow/_subject_id_{subject_id}/antsRegistrationSyN/transformInverseComposite.h5'

 }

selectfiles = Node(SelectFiles(templates,
                               base_directory=experiment_dir),
                   name="selectfiles")

#-----------------------------------------------------------------------------------------------------
# In[1]:
datasink = Node(DataSink(), name = 'datasink')
datasink.inputs.container = output_dir
datasink.inputs.base_directory = experiment_dir

substitutions = [('_subject_id_', '')]

datasink.inputs.substitutions = substitutions


# out = utils.clean_working_directory(clean_working_directory(outputs, tmpdir.strpath, inputs,needed_outputs, deepcopy(config._sections)))
#-----------------------------------------------------------------------------------------------------
# TMBTA_Atlas

TMBTA_Atlas = '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/registration/TMBTA_Brain_Atlas.nii'
TMBTA_to_VBM_trans = '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/registration/VBM_to_TMBTA_InverseComposite.h5'

#-----------------------------------------------------------------------------------------------------

merge_transforms = Node(utility.Merge(2), name = 'merge_transforms')
merge_transforms.inputs.in2 = TMBTA_to_VBM_trans

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Transfer the labels from template space to subject space
atlas_to_subject = Node(ants.ApplyTransforms(), name = 'atlas_to_subject')
atlas_to_subject.inputs.dimension = 3
atlas_to_subject.inputs.input_image = TMBTA_Atlas
atlas_to_subject.inputs.interpolation = 'NearestNeighbor'

#----------------------------------------------------------------------------------------------------
# In[1]:
# I compared ImageMaths LabelStats and LabelGeometryMeasures, they gave exactly the same voxel count in every ROI

#TODO: intracranial volume #depends on the brain extraction, I ain't doing it
#TODO: multiplication for volume size (no. of voxels * 0.1*0.1*0.1)
#TODO: move the transformations to subject space directly by combining two transfomrations

# the implentation inside nipype did not work

def get_VBM_labels_volume(label_image, intensity_image):
    import ants
    label_image = ants.image_read(label_image)
    print (label_image)

    intensity_image = ants.image_read(intensity_image)
    print (intensity_image)
    geom = ants.label_geometry_measures(label_image, intensity_image)
    VBM_labels_volumes = geom.to_csv('VBM_labels_volumes.csv')
    return VBM_labels_volumes

get_VBM_labels_volume = Node(name ='get_VBM_labels_volume',
          interface = Function(input_names = ['label_image', 'intensity_image'],
          output_names = ['VBM_labels_volumes'],
          function = get_VBM_labels_volume))



#-----------------------------------------------------------------------------------------------------
# In[1]:
VBM_labels_volumes_workflow.connect ([

      (infosource, selectfiles,[('subject_id','subject_id')]),
      (selectfiles, merge_transforms, [('inverse_transfroms','in1')]),


      (selectfiles, atlas_to_subject, [('3d_brain_ex','reference_image')]),
      (merge_transforms, atlas_to_subject, [('out','transforms')]),


      (selectfiles, get_VBM_labels_volume, [('3d_brain_ex','intensity_image')]),
      (atlas_to_subject, get_VBM_labels_volume, [('output_image','label_image')]),


  ])


VBM_labels_volumes_workflow.write_graph(graph2use='flat')
VBM_labels_volumes_workflow.run('MultiProc', plugin_args={'n_procs': 4})

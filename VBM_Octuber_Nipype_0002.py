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
from nipype.pipeline.engine import Workflow, Node, MapNode

import numpy as np
import matplotlib.pyplot as plt
from nipype.interfaces.matlab import MatlabCommand
# MatlabCommand.set_default_paths('/media/amr/HDD/Sofwares/spm12/')
MatlabCommand.set_default_matlab_cmd("matlab -nodesktop -nosplash")

#-----------------------------------------------------------------------------------------------------
# In[1]:
experiment_dir = '/home/in/aeed/Work/October_Acquistion/'

subject_list = ['229', '230', '232', '233', '234',
                '235', '236', '237', '242', '243',
                '244', '245', '252', '253', '255',
                '261', '262', '263', '264', '271',
                '272', '273', '274', '281', '282',
                '286', '287', '362', '363', '364',
                '365', '366']

# subject_list = ['Agarose'] # creates an error, I removed it from the list
# subject_list = ['274', '362']


output_dir  = 'VBM/VBM_output_preproc'
working_dir = 'VBM/VBM_workingdir_preproc'

VBM_workflow = Workflow (name = 'VBM_workflow')
VBM_workflow.base_dir = opj(experiment_dir, working_dir)

#-----------------------------------------------------------------------------------------------------
# In[1]:
infosource = Node(IdentityInterface(fields=['subject_id']),
                  name="infosource")
infosource.iterables = [('subject_id', subject_list)]

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Images are already augmented
templates = {

             '3D'       : 'Data/{subject_id}/3D.nii',

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

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Template and priors
study_based_template = '/home/in/aeed/Work/October_Acquistion/VBM/registration/VBM_template_manual_ext.nii.gz'
# study_based_template = '/home/in/aeed/Work/October_Acquistion/VBM/registration/VBM_to_TMBTA_InverseWarped.nii.gz'
study_based_template_mask = '/home/in/aeed/Work/October_Acquistion/VBM/registration/VBM_template_manual_ext_mask.nii.gz'
# study_based_template_mask = '/home/in/aeed/Work/October_Acquistion/VBM/registration/VBM_to_TMBTA_InverseWarped_mask.nii.gz'
GM  = '/home/in/aeed/Work/October_Acquistion/VBM/registration/GM_to_VBM.nii.gz'
WM  = '/home/in/aeed/Work/October_Acquistion/VBM/registration/GM_to_VBM.nii.gz'
CSF = '/home/in/aeed/Work/October_Acquistion/VBM/registration/GM_to_VBM.nii.gz'

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Bias Field Correction
bias_corr = Node(ants.N4BiasFieldCorrection(), name = 'Bias_Field_Correction')
bias_corr.inputs.copy_header = True
bias_corr.inputs.dimension = 3
bias_corr.inputs.n_iterations = [50,50,30,20]
bias_corr.inputs.save_bias = True
bias_corr.inputs.bspline_fitting_distance = 300.0
bias_corr.inputs.bspline_order = 5

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Brain extraction, bias field correction is included inside
brain_ext = Node(ants.BrainExtraction(), name = 'Brain_Extraction')
brain_ext.inputs.dimension = 3
brain_ext.inputs.num_threads = 4
brain_ext.inputs.brain_template = study_based_template
brain_ext.inputs.brain_probability_mask = study_based_template_mask
# brain_ext.inputs.num_threads = 4

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Register to the study-based template
reg_sub_to_temp = Node(ants.Registration(), name = 'antsRegistrationSyN')


#reg_sub_to_temp.inputs.fixed_image=FA_Template
reg_sub_to_temp.inputs.fixed_image=study_based_template

reg_sub_to_temp.inputs.args='--float'
reg_sub_to_temp.inputs.collapse_output_transforms=True
reg_sub_to_temp.inputs.initial_moving_transform_com=True
reg_sub_to_temp.inputs.num_threads=4
reg_sub_to_temp.inputs.output_inverse_warped_image=True
reg_sub_to_temp.inputs.output_warped_image=True
reg_sub_to_temp.inputs.sigma_units=['vox']*3
reg_sub_to_temp.inputs.transforms= ['Rigid', 'Affine', 'SyN']
# reg_sub_to_temp.inputs.terminal_output='file'
reg_sub_to_temp.inputs.winsorize_lower_quantile=0.005
reg_sub_to_temp.inputs.winsorize_upper_quantile=0.995
reg_sub_to_temp.inputs.convergence_threshold=[1e-06]
reg_sub_to_temp.inputs.convergence_window_size=[10]
reg_sub_to_temp.inputs.metric=['MI', 'MI', 'CC']
reg_sub_to_temp.inputs.metric_weight=[1.0]*3
reg_sub_to_temp.inputs.number_of_iterations=[[1000, 500, 250, 100],
                                                 [1000, 500, 250, 100],
                                                 [100, 70, 50, 20]]
reg_sub_to_temp.inputs.radius_or_number_of_bins=[32, 32, 4]
reg_sub_to_temp.inputs.sampling_percentage=[0.25, 0.25, 1]
reg_sub_to_temp.inputs.sampling_strategy=['Regular',
                                              'Regular',
                                              'None']
reg_sub_to_temp.inputs.shrink_factors=[[8, 4, 2, 1]]*3
reg_sub_to_temp.inputs.smoothing_sigmas=[[3, 2, 1, 0]]*3
reg_sub_to_temp.inputs.transform_parameters=[(0.1,),
                                                 (0.1,),
                                                 (0.1, 3.0, 0.0)]
reg_sub_to_temp.inputs.use_histogram_matching=True
reg_sub_to_temp.inputs.write_composite_transform=True
reg_sub_to_temp.inputs.verbose=True
reg_sub_to_temp.inputs.output_warped_image=True
reg_sub_to_temp.inputs.float=True
# reg_sub_to_temp.inputs.num_threads = 4
#-----------------------------------------------------------------------------------------------------
# In[1]:
#Transform Compositetransform to a warpfield to use it with CreateJacobian
calc_warp_field = Node(ants.ApplyTransforms(), name = 'Calc_Warp_Field')
calc_warp_field.inputs.reference_image = study_based_template
calc_warp_field.inputs.dimension = 3
calc_warp_field.inputs.print_out_composite_warp_file = True
calc_warp_field.inputs.output_image = 'Warp_Field.nii.gz'

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Create jacobian determinant
jacobian = Node(ants.CreateJacobianDeterminantImage(), name = 'Calculate_Jacobian_Determinant')
jacobian.inputs.imageDimension = 3
jacobian.inputs.outputImage = 'Jacobian.nii.gz'

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Denoise, obviuosly it improves the segmentation
denoise = Node(ants.DenoiseImage(), name = 'denoise_image')
denoise.inputs.dimension = 3
denoise.inputs.output_image = 'denoised.nii.gz'
#-----------------------------------------------------------------------------------------------------



# In[1]:
#Tissue segmentation
atropos = Node(ants.Atropos(), name = 'Atropos')

atropos.inputs.dimension = 3
atropos.inputs.initialization = 'KMeans'
atropos.inputs.prior_probability_images = [CSF,GM,WM]
atropos.inputs.number_of_tissue_classes = 6
atropos.inputs.prior_weighting = 0.8
atropos.inputs.prior_probability_threshold = 0.0000001
atropos.inputs.likelihood_model = 'Gaussian'
atropos.inputs.mrf_smoothing_factor = 0.0125
atropos.inputs.mrf_radius = [1, 1, 1]
atropos.inputs.n_iterations = 10
atropos.inputs.convergence_threshold = 0.000001
atropos.inputs.posterior_formulation = 'Socrates'
atropos.inputs.use_mixture_model_proportions = True
atropos.inputs.save_posteriors = True

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Get the grey matter
#This is the only way to choose one output out of a list of outputs
#here posteriors and I want only posterior_02, that is corresponding to gm

def Get_GM(posteriors):
	import nibabel as nb
	input = posteriors
	GM1 = posteriors[3] #posterior_04
	GM2 = posteriors[4] #posterior_05
	print (GM1, GM2)
	return GM1, GM2

get_gm = Node(name ='Get_GM',
          interface = Function(input_names = ['posteriors'],
          output_names = ['GM1', 'GM2'],
          function = Get_GM))
#-----------------------------------------------------------------------------------------------------
# In[1]:
# add two tissue priors to get the most reasonable GM tissue prior
add_two_priors = Node(fsl.BinaryMaths(), name = 'add_two_priors')
add_two_priors.inputs.operation = 'add'




#-----------------------------------------------------------------------------------------------------
# In[1]:
#Make a mask of the warped image, to use it with atropos
binarize_warped_image = Node(fsl.UnaryMaths(), name = 'Binarize_Warped_Image')
binarize_warped_image.inputs.operation = 'bin'
binarize_warped_image.output_datatype = 'char'

#-----------------------------------------------------------------------------------------------------
# In[1]:
#Multiply by Jacobian determinant to ge the modulate image
modulate_GM = Node(ants.MultiplyImages(), name = 'Modulate_GM')
modulate_GM.inputs.dimension = 3
modulate_GM.inputs.output_product_image = 'Modulated_GM.nii.gz'


#-----------------------------------------------------------------------------------------------------
# In[1]:
#Smooth the modulated images
smoothing = Node(fsl.Smooth(), name = 'Smoothing')
smoothing.iterables = ('fwhm', [1.5, 2, 2.3,2.7,3])

#-----------------------------------------------------------------------------------------------------
# In[1]:
VBM_workflow.connect ([

      (infosource, selectfiles,[('subject_id','subject_id')]),
      (selectfiles, bias_corr, [('3D','input_image')]),
      (bias_corr, brain_ext, [('output_image','anatomical_image')]),
      (brain_ext, reg_sub_to_temp, [('BrainExtractionBrain','moving_image')]),


      (reg_sub_to_temp, calc_warp_field, [('composite_transform','transforms')]),
      (brain_ext, calc_warp_field, [('BrainExtractionBrain','input_image')]),

      (calc_warp_field, jacobian, [('output_image','deformationField')]),
#------------------------------------------------------------------------------------
      (reg_sub_to_temp, binarize_warped_image, [('warped_image','in_file')]),
      (reg_sub_to_temp, denoise, [('warped_image','input_image')]),

      (denoise, atropos, [('output_image','intensity_images')]),
      (binarize_warped_image, atropos, [('out_file','mask_image')]),

      (atropos, get_gm, [('posteriors','posteriors')]),

      (get_gm, add_two_priors, [('GM1','operand_file')]),
      (get_gm, add_two_priors, [('GM2','in_file')]),

      (add_two_priors, modulate_GM, [('out_file','first_input')]),
      (jacobian, modulate_GM, [('jacobian_image','second_input')]),

      (modulate_GM, smoothing, [('output_product_image','in_file')]),

  ])


VBM_workflow.write_graph(graph2use='colored', format='png', simple_form=True)
VBM_workflow.run(plugin='SLURM',plugin_args={'dont_resubmit_completed_jobs': True, 'max_jobs':50})
# VBM_workflow.run(plugin='MultiProc',plugin_args={'n_procs':8})

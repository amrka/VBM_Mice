# running correlation analysis for OF and EPM using different designs
# each design represents one varible
# we have 32 animals in VBM analysis - two contrasts, +ve and -ve correlation
# hence we have 30 dof, degrees of freedom
from nipype import config
cfg = dict(execution={'remove_unnecessary_outputs': False})
config.update_config(cfg)
#-------------------------------------------------------------------------------------
import nipype.interfaces.fsl as fsl
import nipype.interfaces.afni as afni
import nipype.interfaces.ants as ants
import nipype.interfaces.spm as spm
import nipype.interfaces.utility as utility
from nipype.interfaces.utility import IdentityInterface, Function
from os.path import join as opj
from nipype.interfaces.io import SelectFiles, DataSink
from nipype.pipeline.engine import Workflow, Node, MapNode
import numpy as np
import matplotlib.pyplot as plt
#-------------------------------------------------------------------------------------
experiment_dir = '/media/amr/Amr_4TB/Work/October_Acquistion/'


map_list=  ['VBM_stats']

output_dir  = 'VBM/VBM_correlation_analysis_outputdir'
working_dir = 'VBM/VBM_correlation_analysis_workingdir'

VBM_corr = Workflow (name = 'VBM_correlation_analysis')
VBM_corr.base_dir = opj(experiment_dir, working_dir)
#-------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
infosource = Node(IdentityInterface(fields=['map_id']),
                  name="infosource")
infosource.iterables = [('map_id', map_list)]

#-----------------------------------------------------------------------------------------------------
templates = {

             'VBM'       : 'VBM/{map_id}/VBM_FWHM_3_mod_GM.nii',
             'VBM_mask'  : 'VBM/{map_id}/VBM_template_manual_ext_mask.nii'

 }

selectfiles = Node(SelectFiles(templates,
                               base_directory=experiment_dir),
                   name="selectfiles")

#-----------------------------------------------------------------------------------------------------
datasink = Node(DataSink(), name = 'datasink')
datasink.inputs.container = output_dir
datasink.inputs.base_directory = experiment_dir

substitutions = [('_map_id_', '')]

datasink.inputs.substitutions = substitutions
#-----------------------------------------------------------------------------------------------------
def palm_corr(in_file, mask_file, design, contrast):
    import os
    from glob import glob
    from nipype.interfaces.base import CommandLine

    designs = [
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_open_to_close_ratio.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_center.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_center_percent.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_closed_arms.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_closed_arms_percent.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_opened_arms.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_opened_arms_percent.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_total_distance.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_velocity.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_center_corners_ratio.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_percent_in_center.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_percent_in_corners.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_sec_in_center.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_total_distance.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_total_time_in_corners.mat',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_velocity.mat']

    contrasts = [
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_open_to_close_ratio.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_center.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_center_percent.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_closed_arms.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_closed_arms_percent.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_opened_arms.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_time_in_opened_arms_percent.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_total_distance.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/EPM_velocity.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_center_corners_ratio.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_percent_in_center.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_percent_in_corners.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_sec_in_center.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_total_distance.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_total_time_in_corners.con',
    '/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr_designs/OF_velocity.con']


    cmd = ("palm \
    -i {in_file} \
    -m {mask_file} \
    -d {design} -t {contrast} \
    -T -noniiclass -n 10 -corrcon -save1-p -o palm_corr_vbm")


    cl = CommandLine(cmd.format(in_file=in_file, mask_file=mask_file, design=design, contrast=contrast ))
    results = cl.run()

palm_corr = MapNode(name = 'palm_corr', iterfield = ['design', 'contrast'],
                 interface = Function(input_names = ['in_file', 'mask_file'],
                                      function = palm_corr))

palm_corr.inputs.design = designs
palm_corr.inputs.contrast = contrasts
#-----------------------------------------------------------------------------------------------------
VBM_corr.connect ([

      (infosource, selectfiles,[('map_id','map_id')]),

      (selectfiles, palm_corr, [('VBM','in_file')]),
      (selectfiles, palm_corr, [('VBM_mask','mask')]),
  ])


VBM_corr.write_graph(graph2use='colored', format='png', simple_form=True)
# VBM_corr.run(plugin='SLURM', plugin_args={'dont_resubmit_completed_jobs': True,'max_jobs':50})
VBM_corr.run('MultiProc', plugin_args={'n_procs': 8})

#!/bin/bash
#perform correlaiton analysis between behavior metrics and VBM smoothed images
# first copy the metrics from the ouput of the behavior ouput to here
# I am suspecting that a lot of the metrics are linear combinations of the others


# Copy the file that contains all the begavior:
# OF: /media/amr/Amr_4TB/Work/October_Acquistion/Open_Field_output/open_field_gp_names.csv
# EPM: /media/amr/Amr_4TB/Work/October_Acquistion/Plus_Maze_output/plus_maze_gp_names.csv


# for each column, I subtract the mean and create design from each one of them
# in those cases the DOF will be 32-2 (rows - columns(contrasts))

mkdir /media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr

cp \
/media/amr/Amr_4TB/Work/October_Acquistion/Open_Field_output/open_field_gp_names.csv \
/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr

cp \
/media/amr/Amr_4TB/Work/October_Acquistion/Plus_Maze_output/plus_maze_gp_names.csv \
/media/amr/Amr_4TB/Work/October_Acquistion/VBM/VBM_corr

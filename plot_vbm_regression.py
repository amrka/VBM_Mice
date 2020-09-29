# plot the regression of VBM with behavioral parameters
# the function should take the smoothed 4D VBM, the behavioral design.mat and a voxel coordinate to extract
# values from
# the function should return one plot and r value
# the voxel coordinate should be a list

# the second version (see git log) replaces the voxel coordinates with a P value image
# it imports the P value image, get the coordinates of the voxel of the highest value
# then use this coordinates to to the voxel_values


def plot_vbm_correlation(vbm_4D_image, mat, p_value_image):
    import numpy as np
    import matplotlib.pyplot as plt
    import nipype.interfaces.fsl as fsl
    import ntpath
    import sys
    import matplotlib
    import os

    img_basename_no_ext = ntpath.basename(vbm_4D_image)[:-7]
    mat_basename_no_ext = ntpath.basename(mat)[:-4]

    contrast_no = ntpath.basename(p_value_image)[-9:-7]

# get the coordinates of voxel with highest p value
    fslstats = fsl.ImageStats()
    fslstats.inputs.in_file = p_value_image
    fslstats.inputs.op_string = '-x'  # returns co-ordinates of maximum voxel
    stat_output = fslstats.run()
    voxel_coordinate = stat_output.outputs.out_stat
    # convert coordinates to int from float to suit fslmeants
    voxel_coordinate = [int(dim) for dim in voxel_coordinate]


# we use fslmeants from fsl to get the intensity of the 4D image from a specific coordinate
# fslmeants -i 4d_image -c 47 73 9
    fslmeants = fsl.ImageMeants()
    fslmeants.inputs.in_file = vbm_4D_image
    fslmeants.inputs.spatial_coord = voxel_coordinate
    outputs = fslmeants.run()
    # here the output is not displayed on the screen, rather as a simple txt
    # the return results are in dict format, we extract the name of the file
    ts = outputs.outputs.get()['out_file']
    voxel_values = np.loadtxt(ts)  # returns the values as an array
    voxel_values = list(voxel_values)

    # now we extract the behavior vector from .mat file
    f = open(mat, 'r')
    lines = f.readlines()
    f.close()
    behav = []
    i = 5
    for item in lines:
        while i < 37:
            behav.append(float(lines[i][13:-2]))
            i = i + 1
            # now we have a list
    # sanity check
    print("length of voxel_values -> {0}".format(len(voxel_values)))
    print("length of behav_values -> {0}".format(len(behav)))
    if len(voxel_values) != len(behav):
        sys.error('######ERROR####')

    # the regression line
    coef = np.polyfit(voxel_values, behav, 1)
    poly1d_fn = np.poly1d(coef)

    # get the correlation coeeficient
    # round to 4 digits after the decimal point
    correlation_coef = round(np.corrcoef(voxel_values, behav)[0, 1], 5)

    plt.rcParams['font.family'] = 'Arial'

    ax = plt.axes()
    ax.spines['bottom'].set_color('#ffffffff')
    ax.spines['top'].set_color('#ffffffff')
    ax.spines['right'].set_color('#ffffffff')
    ax.spines['left'].set_color('#ffffffff')
    ax.tick_params(axis='x', colors='#ffffffff')
    ax.tick_params(axis='y', colors='#ffffffff')

    plt.xticks(fontsize=14, rotation=45, color='#ffffffff')
    plt.yticks(fontsize=14, color='#ffffffff')
    plt.scatter(voxel_values[:16], behav[:16], marker='o', color='#377eb899')
    plt.scatter(voxel_values[16:], behav[16:], marker='<', color='#e41a1c99')
    plt.ylabel("{0}".format(mat_basename_no_ext), fontsize=18, fontname='Arial', color='#ffffffff')
    plt.plot(voxel_values, poly1d_fn(voxel_values), color='#ffffffff')  # plot the regression line
    # type the coef on the graph, first two arguments the coordinates of the text (top left corner)
    plt.text(min(voxel_values), max(behav), "r $= {0}$".format(
        correlation_coef), fontname="Arial", style='italic', fontsize=14, color='#ffffffff')

    plt.savefig("/Users/amr/Dropbox/thesis/3D/VBM_corr/{0}_{1}_{2}.svg".format(
        img_basename_no_ext, mat_basename_no_ext, contrast_no), format='svg')
    plt.close()

    os.remove(ts)  # delete the file of the voxel values as it is no longer needed
    os.remove('stat_result.json')


# =======================================================================================================
# VBM FWHM_3

vbm_4D_image = '/Volumes/Amr_1TB/VBM/VBM_stats/VBM_FWHM_3_mod_GM.nii'
mat = '/Volumes/Amr_1TB/VBM/VBM_corr_designs/EPM_time_in_center_percent.mat'
p_value_image = '/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz'


plot_vbm_correlation(vbm_4D_image, mat, p_value_image)


vbm_4D_image = '/Volumes/Amr_1TB/VBM/VBM_stats/VBM_FWHM_3_mod_GM.nii'
mat = '/Volumes/Amr_1TB/VBM/VBM_corr_designs/EPM_time_in_center_percent.mat'
p_value_image = '/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center_percent.con_EPM_time_in_center_percent.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz'


plot_vbm_correlation(vbm_4D_image, mat, p_value_image)


vbm_4D_image = '/Volumes/Amr_1TB/VBM/VBM_stats/VBM_FWHM_3_mod_GM.nii'
mat = '/Volumes/Amr_1TB/VBM/VBM_corr_designs/EPM_time_in_center.mat'
p_value_image = '/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c1.nii.gz'


plot_vbm_correlation(vbm_4D_image, mat, p_value_image)


vbm_4D_image = '/Volumes/Amr_1TB/VBM/VBM_stats/VBM_FWHM_3_mod_GM.nii'
mat = '/Volumes/Amr_1TB/VBM/VBM_corr_designs/EPM_time_in_center.mat'
p_value_image = '/Users/amr/Dropbox/thesis/3D/VBM_corr/EPM_time_in_center.con_EPM_time_in_center.mat/palm_corr_vbm_tfce_tstat_fwep_c2.nii.gz'


plot_vbm_correlation(vbm_4D_image, mat, p_value_image)

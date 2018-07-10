%% smooth_Amat
% Performs Gaussian smoothing on a sensitivity matrix.
%
%% Description
% |iA_out = smooth_Amat(iA_in, info, dim)| takes the inverted VOX x MEAS
% sensitivity matrix |iA_in| and performs Gaussian smoothing in the 3D voxel 
% space on each of the concatenated wavelength matrices within, returning
% it as |iA_out|. The calculation is parallelized by MEAS, and only good
% voxels as defined by the |dim.Good_Vox| field are used to reduce
% calculation time.
%
% |iA_out = smooth_Amat(iA_in, info, dim, gbox, gsigma)| allows the user to
% specify the Gaussian filter size |gbox| and the filter width |gsigma|. If
% no values or the empty matrix are supplied for these inputs, |gbox| and
% |gsigma| will default to values of |5| and |1.2|, respectively.
%
% |iA_out = smooth_Amat(iA_in, dim, gbox, gsigma, tflag)| allows the user
% to smooth the sensitivity matrix in the MEAS x VOX orientation (for
% instance, if it is desired to perform smoothing before inversion) if
% |tflag| is |1|.
% 
%% See Also
% <Tikhonov_invert_Amat_help.html Tikhonov_invert_Amat> |
% <reconstruct_img_help.html reconstruct_img> | <FindGoodMeas_help.html
% FindGoodMeas>
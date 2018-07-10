%% Tikhonov_invert_Amat
% Inverts a sensitivity matrix.
%
%% Description
% |iA = Tikhonov_invert_Amat(A)| takes a MEAS x VOX device sensitivity
% matrix |A| and performs a Tikhonov inversion, returning it as a VOX x
% MEAS matrix |iA|.
%
% |iA = Tikhonov_invert_Amat(A, lambda1, lambda2)| allows the user to
% specify the values of the |lambda1| and |lambda2| parameters in the
% inversion calculation. The default values are |0.01| and |0.1|,
% respectively.
%
%% See Also
% <smooth_Amat_help.html smooth_Amat> | <reconstruct_img_help.html
% reconstruct_img> | <FindGoodMeas_help.html FindGoodMeas>
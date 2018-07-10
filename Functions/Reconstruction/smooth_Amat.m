function iA_out = smooth_Amat(iA_in, dim, gbox, gsigma, tflag)

% SMOOTH_AMAT Performs Gaussian smoothing on a sensitivity matrix.
%
%   iA_out = SMOOTH_AMAT(iA_in, dim) takes the inverted VOX x MEAS
%   sensitivity matrix "iA_in" and performs Gaussian smoothing in the 3D
%   voxel space on each of the concatenated wavelength matrices within,
%   returning it as "iA_out". The calculation is parallelized by MEAS, and
%   only good voxels as defined by the "dim.Good_Vox" field are used to
%   reduce calculation time.
%
%   iA_out = SMOOTH_AMAT(iA_in, dim, gbox, gsigma) allows the user to
%   specify the Gaussian filter size "gbox" and the filter width "gsigma".
%   If no values or the empty matrix are supplied for these inputs, "gbox"
%   and "gsigma" will default to values of 5 and 1.2, respectively.
% 
%   iA_out = SMOOTH_AMAT(iA_in, dim, gbox, gsigma, tflag) allows the user
%   to smooth the sensitivity matrix in the MEAS x VOX orientation (for
%   instance, if it is desired to perform smoothing before inversion) if
%   "tflag" is 1.
%
% See Also: TIKHONOV_INVERT_AMAT, RECONSTRUCT_IMG, FINDGOODMEAS.

%% Parameters and Initialization.
[Nvox, Nm] = size(iA_in);
iA_out = zeros(Nvox, Nm, 'single');
kernel_size = [1, 1, 1];

nVx = dim.nVx;
nVy = dim.nVy;
nVz = dim.nVz;

if ~exist('gbox', 'var')  ||  isempty(gbox)
    gbox = 5;
end
if ~exist('gsigma', 'var')  ||  isempty(gsigma)
    gsigma = 1.2;
end
if ~exist('tflag', 'var')  ||  isempty(tflag)
    tflag = 0;
end

gbox = round(gbox / dim.sV);
gsigma = gsigma / dim.sV;
if ~mod(gbox, 2)
    gbox = gbox + 1;
end

%% Transpose if in MEAS x VOX orientation.
if tflag
    iA_in = iA_in';
end

%% Preallocate voxel space.
if isfield(dim, 'Good_Vox')
    GV = dim.Good_Vox;
else
    GV = ones(nVx, nVy, nVz); % WARNING: THIS RUNS WAY SLOWER.
end

%% Do smoothing in parallel.
parpool
parfor k = 1:Nm
    iAvox = zeros(nVx, nVy, nVz); % Set up temp iAvox
    iAvox(GV) = iA_in(:, k); % Grab iA vox for a meas
    iAvox = smooth3(iAvox, 'gaussian', gbox * kernel_size, gsigma); % smooth
    iA_out(:, k) = single(iAvox(GV)); % Put back into vector form on the way out.
end

%% Shut down pool so this can be re-run.
delete(gcp('nocreate'))

%% De-transpose if in MEAS x VOX orientation.
if tflag
    iA_out = iA_out';
end



%

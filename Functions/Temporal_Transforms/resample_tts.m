function [data_out, info_out] = resample_tts(data_in, info_in, omega_resample, tol, framerate)

% RESAMPLE_TTS Resample data while maintaining linear signal component.
%
%   [data_out, info_out] = RESAMPLE_TTS(data_in, info_in, tHz, tol,
%   framerate) takes a raw light-level data array "data_in" of the format
%   MEAS x TIME, and resamples it (typically downward) to a new frequency
%   using the built-in MATLAB function RESAMPLE. The new sampling frequency
%   is calculated as the ratio of input "omega_resample" divided by
%   "framerate" (both scalars), to within the tolerance specified by "tol".
%
%   This function is needed because the linear signal components, which can
%   be important in other NeuroDOT pipeline calculations, can be
%   inadvertently removed by downsampling using RESAMPLE alone.
%
%   Note: This function resamples synch points in addition to data. Be sure
%   to take care that your data and synch points match after running this
%   function! "info.paradigm.init_synchpts" stores the original synch
%   points if you need to restore them.
%
% See Also: DETREND_TTS, RESAMPLE.

%% Parameters and Initialization.
info_out = info_in;

dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2);

if ~exist('framerate', 'var')  ||  isempty(framerate)
    if isfield(info_in, 'system')  &&  ~isempty(info_in.system)...
            && isfield(info_in.system, 'framerate')  &&  ~isempty(info_in.system.framerate)
        framerate = info_in.system.framerate;
    else
        framerate = 10.0005;
    end
end
if ~exist('omega_resample', 'var')  ||  isempty(omega_resample)
    omega_resample = 1;
end
if ~exist('tol', 'var')  ||  isempty(tol)
    tol = 1e-5;
end

%% N-D Input.
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Approximate desired resampling ratio as a fraction.
[N, D] = rat(omega_resample / framerate, tol);
info_out.system.framerate = omega_resample;

%% Remove linear fit.
[~, Nt] = size(data_in);
d0 = data_in(:, 1); % start point
dF = data_in(:, Nt); % end point
beta = -d0;

alpha1 = (d0 - dF) ./ (Nt - 1); % slope for linear fit
alpha_full = bsxfun(@times, [0:(Nt - 1)], alpha1);
correction = bsxfun(@plus, alpha_full, beta); % correction for linear
corrsig = data_in + correction;

%% Resample with endpoints pinned to zero.
rawresamp = resample(corrsig', N, D)';

%% Add linear fit back to resampled data.
alpha2 = alpha1 * (D / N); % DO NOT GET FANCY AND REPLACE "D / N". CAUSES PRECISION ERROR.
[~, Nt] = size(rawresamp);
alpha_full = bsxfun(@times, [0:(Nt - 1)], alpha2);
correction = bsxfun(@plus, alpha_full, beta);
data_out = rawresamp - correction;

%% Fix synch pts to new framerate.
info_out.paradigm.synchpts = round(N .* info_out.paradigm.synchpts ./ D);
info_out.paradigm.synchpts(info_out.paradigm.synchpts == 0) = 1;

%% N-D Output.
if NDtf
    data_out = reshape(data_out, [dims(1:end-1), Nt]);
end



%

function iA = Tikhonov_invert_Amat(A, lambda1, lambda2)

% TIKHONOV_INVERT_AMAT Inverts a sensitivity matrix.
%
%   iA = TIKHONOV_INVERT_AMAT(A) takes a MEAS x VOX device
%   sensitivity matrix "A" and performs a Tikhonov inversion, returning it
%   as a VOX x MEAS matrix "iA".
%
%   iA = TIKHONOV_INVERT_AMAT(A, lambda1, lambda2) allows the user to
%   specify the values of the "lambda1" and "lambda2" parameters in the
%   inversion calculation. The default values are 0.01 and 0.1,
%   respectively.
%
% See Also: SMOOTH_AMAT, RECONSTRUCT_IMG, FINDGOODMEAS.

%% Parameters and Initialization.
[Nm, Nvox] = size(A);
iA = zeros(Nvox, Nm, 'single');

if (nargin == 2)  ||  isempty(lambda1)
    lambda1 = 0.01;
end
if (nargin <= 3)  ||  isempty(lambda2)
    lambda2 = 0.1;
end

%% Construct regularization matrix L.
AtA = sum(A .^ 2, 1); % diag(L) = diag(A'A) (shortcut)
L = sqrt(AtA + lambda2 * max(AtA)); % Adjust with beta cut-off value

%% Spatially normalize A-matrix.
A = bsxfun(@rdivide, A, L);

%% Take the pseudo-inverse.
if Nvox < Nm
    Att = zeros(Nvox, 'single'); % Preallocate
    Att = single(A' * A);
    ss = normest(Att); % normest used because Nvox x Nvox "Att" array is very large.
    penalty = sqrt(ss) .* lambda1;
    iA = (Att + penalty .^ 2 .* eye(Nvox, 'single')) \ A';
else
    Att = zeros(Nm, 'single'); % Preallocate
    Att = single(A * A');
    ss = norm(Att);
    penalty = sqrt(ss) .* lambda1;
    iA = A' / (Att + penalty .^ 2 .* eye(Nm, 'single'));
end

%% Undo spatial regularization.
iA = bsxfun(@rdivide, iA, L');


%

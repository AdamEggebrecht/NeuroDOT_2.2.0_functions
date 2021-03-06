function info_out = FindGoodMeas(data, info_in, bthresh)

% FINDGOODMEAS Performs "Good Measurements" analysis.
%
%   info_out = FINDGOODMEAS(data, info_in) takes a light-level array "data"
%   in the MEAS x TIME format, and calculates the variance of each channel
%   as its noise level. These are then thresholded by the default value of
%   0.075 to create a logical array, and both are returned as MEAS x 1
%   columns of the "info.MEAS" table. If pulse synch point information
%   exists in "info.system.synchpts", then FINDGOODMEAS will crop the data
%   to the start and stop pulses.
%
%   info_out = FINDGOODMEAS(data, info_in, bthresh) allows the user to
%   specify a threshold value.
%
% See Also: PLOTCAPGOODMEAS, PLOTHISTOGRAMSTD.

%% Parameters and Initialization.
info_out = info_in;
weight = 1; % Hardcoded from ND2.

if ~exist('bthresh', 'var')
    bthresh = 0.075; % Empirically derived threshold value.
end

%% Crop data to synchpts if necessary.
if isfield(info_out.paradigm, 'synchpts')
    NsynchPts = length(info_out.paradigm.synchpts); % set timing of data
    if NsynchPts > 2
        tF = info_out.paradigm.synchpts(end);
        t0 = info_out.paradigm.synchpts(2);
    elseif NsynchPts == 2
        tF = info_out.paradigm.synchpts(2);
        t0 = info_out.paradigm.synchpts(1);
    else
        tF = size(data, 2);
        t0 = 1;
    end
    STD = std(data(:, t0:tF), weight, 2); % Calculate STD
else
    STD = std(data, weight, 2);
end

%% Create new table of on-the-fly calculated stuff.
info_out.MEAS = table(STD, STD <= bthresh,...
    'VariableNames', {'STD', 'GI'});



%

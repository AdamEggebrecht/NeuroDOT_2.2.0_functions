function data_out = BlockAverage(data_in, info, pulse, dt)

% BLOCKAVERAGE Averages data by stimulus blocks.
%
%   data_out = BLOCKAVERAGE(data_in, info) takes a light-level array
%   "data_in" of the MEAS x TIME format, and uses the experiment
%   information from "info" to cut that data timewise into blocks of equal
%   length, which are then averaged together and output as "data_out".
%
%   data_out = BLOCKAVERAGE(data_in, info, pulse) allows the user to select
%   which synchronization pulse to block average. The default is
%   "info.paradigm.Pulse_2", but other pulses can be designated with either
%   a string ("Pulse_3" or "4") or number (5) input.
%
%   data_out = BLOCKAVERAGE(data_in, info, pulse, dt) allows the user to
%   manually input the block length "dt", as either a string or number.
%
% See Also: NORMALIZE2RANGE_TTS.

%% Parameters and Initialization.
dims = size(data_in);
Nt = dims(end); % Assumes time is always the last dimension.
NDtf = (ndims(data_in) > 2);

if ~exist('pulse', 'var')
    pulse = 'Pulse_2';
end
if isnumeric(pulse)
    pulse = ['Pulse_', num2str(pulse)];
elseif ischar(pulse)  &&  isempty(strfind(pulse, 'Pulse_'))
    pulse = ['Pulse_', pulse];
end

% These need to be calculated after "pulse" is nailed down.
Nbl = length(info.paradigm.(pulse));

if ~exist('dt', 'var')
    dt = round(mean(diff(info.paradigm.synchpts(info.paradigm.(pulse)))));
elseif ischar(dt)
    dt = str2double(dt);
end

% Check to make sure that the block after the last synch point for this
% pulse does not exceed the data's time dimension. This usually happens on
% Pulse_3.
if dt + info.paradigm.synchpts(info.paradigm.(pulse)(end)) > Nt
    Nbl = Nbl - 1;
end

%% N-D Input (for 3-D or N-D voxel spaces).
if NDtf
    data_in = reshape(data_in, [], Nt);
end

%% Cut data into blocks.
for k = 1:Nbl
    blstart = info.paradigm.synchpts(info.paradigm.(pulse)(k));
    blocks(:, :, k) = data_in(:, blstart:blstart + dt - 1);
end

%% Average blocks and return.
data_out = mean(blocks, 3);

%% N-D Output.
if NDtf
    data_out = reshape(data_out, [dims(1:end-1), dt]);
end



%

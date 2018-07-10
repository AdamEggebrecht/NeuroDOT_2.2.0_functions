%% BlockAverage
% Averages data by stimulus blocks.
%
%% Description
% |data_out = BlockAverage(data_in, info)| takes a light-level array
% |data_in| of the MEAS x TIME format, and uses the experiment information
% from |info| to cut that data timewise into blocks of equal length, which
% are then averaged together and output as |data_out|.
% 
% |data_out = BlockAverage(data_in, info, pulse)| allows the user to select
% which synchronization pulse to block average. The default is
% |info.paradigm.Pulse_2|, but other pulses can be designated with either a
% string (|'Pulse_3'| or |'4'|) or number (|5|) input.
% 
% |data_out = BlockAverage(data_in, info, pulse, dt)| allows the user to
% manually input the block length |dt|, as either a string or number.
%
%% See Also
% <normalize2range_tts_help.html normalize2range_tts> 



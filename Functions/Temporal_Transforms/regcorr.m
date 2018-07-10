function [data_out, R] = regcorr(data_in, info, hem)

% REGCORR Performs regression correction by wavelengths.
%
%   [data_out, R] = REGCORR(data_in, info, hem) takes a light-level data
%   array "data_in" of the format MEAS x TIME, and using the scan metadata
%   in "info.pairs" and a WL x MEAS "hem" array generated by GETHEM,
%   performs a regression correction for each wavelength of the data, which
%   is returned in the MEAS x TIME array "data_out". The corresponding
%   correlation coefficients for each measurement are returned in "R" as a
%   MEAS x 1 array.
%
%   The formal equation for the regression is:
%       x_hat = x - h * hp * x;
%   where x is the transpose (TIME x MEAS) of the original data for a
%   single wavelength, h is the hem transpose (TIME x 1) for a single
%   wavelength, hp is the pseudoinverse (1 x TIME) of h, and x_hat is the
%   estimation of the true x.
%
% See Also: GETHEM, DETREND_TTS.

%% Parameters and Initialization.
[Nm, Nt] = size(data_in);
cs = unique(info.pairs.WL); % WLs.
Nc = length(cs); % Number of WLs.
data_out = zeros(Nm, Nt);
R = zeros(Nm, 1);

%% Regression correction.
for k = 1:Nc
    keep = info.pairs.WL == cs(k); % get current color
    temp = data_in(keep, :)';
    
    g = hem(k, :)'; % regressor/noise signal in correct orientation
    gp = pinv(g);
    beta = gp * temp;
    data_out(keep, :) = (temp - g * beta)'; % linear regression
    R(keep) = normr(g') * normc(temp); % correlation coefficient
end



%

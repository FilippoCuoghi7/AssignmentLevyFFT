function [BP, details] = computeBlackPrice(df_mat, mkt_data, ref_date, mat_date)
% COMPUTE_BLACK_PRICE Calculates the price of a Digital Call option
% using the pure Black (1976) model, without any smile adjustments.
%
% INPUTS:
%   df_mat   : The exact interpolated discount factor at maturity B(t0, t).
%   mkt_data : Structure array containing the market dataset. Must contain
%              the struct with reference, strikes, dividends, and surface fields.
%   ref_date : The initial valuation date of the contract.
%   mat_date : The maturity date of the option.
%
% OUTPUTS:
%   BP       : The price of the pure Black digital option assuming a 1 EUR payoff.
%   details  : Struct containing variables for the report.

% Calculate Time to Maturity (T) in years (Act/365)
T = yearfrac(ref_date, mat_date, 3);

% Extract market parameters
S0 = mkt_data.cSelect.reference;
q = mkt_data.cSelect.dividends;
strikes = mkt_data.cSelect.strikes;
vols_1y = mkt_data.cSelect.surface;

% Calculate the ATM Forward Price (F0) using Garman-Kohlhagen 
F0 = (S0 * exp(-q * T)) / df_mat;

% ATM Fwd
K = F0;

% Interpolate the volatility exactly at K using 'spline'
sigma = interp1(strikes, vols_1y, K, 'spline');

% Compute d2 under Black 76 model
d2 = (log(F0 ./ K) - 0.5 * sigma.^2 .* T) ./ (sigma .* sqrt(T));

% Compute the CDF for d2
Nd2 = normcdf(d2);

% Compute the Black Price for the Digital Option
BP = df_mat * Nd2;

% Details for the report
details = struct();

details.T = T;
details.F0 = F0;
details.sigma = sigma;

end
function [F0, vol, slope] = computeSlopeCorrectiveTerm(mkt_data, df_mat, ref_date, end_date)
% COMPUTE_SLOPE_CORRECTIVETERM Calculates the derivative of the implied
% volatility with respect to the strike price using a cubic spline interpolation
% and a precise central difference method.
%
% INPUTS:
%   mkt_data : A structure array containing the market dataset.
%              It must contain a nested struct named 'cSelect' with the
%              following specific fields:
%              - .reference : The scalar Spot Price (S0).
%              - .strikes   : A column vector of market strike prices.
%              - .surface   : A column vector of 1-year implied volatilities
%                             corresponding to the strikes.
%  df_mat    : The discount from the reference date up to the maturity date.
%  ref_date  : The starting date of the contract.
%  end_date  : The maturity date of the contract.
%
% OUTPUTS:
%   F0       : The extracted Fwd Price, which serves as the ATM anchor.
%   vol      : The implied volatility at the ATM anchor.
%   slope    : The computed numerical derivative (dSigma/dK) evaluated exactly at S0.

% Extract the Spot Price (S0) and dividend yield
S0 = mkt_data.cSelect.reference;
q = mkt_data.cSelect.dividends;

% Extract the vector of strikes and vols
strikes = mkt_data.cSelect.strikes;
vols_1y = mkt_data.cSelect.surface;

% ---------------------------------------------------------
% SLOPE CALCULATION (Spline Interpolation)
% ---------------------------------------------------------

% Compute the yearfrac between start_date and end_date (ACT/365)
T = yearfrac(ref_date, end_date, 3);

% Compute Fwd price
F0 = S0 * exp(- q * T)/df_mat;

% ATM Fwd
K = F0;

% Define a tiny shift (epsilon) for the numerical derivative
epsilon = 0.001;

% Interpolate the volatility exactly at K, a tiny bit above K, and below K
vol      = interp1(strikes, vols_1y, K, 'spline');
vol_up   = interp1(strikes, vols_1y, K + epsilon, 'spline');
vol_down = interp1(strikes, vols_1y, K - epsilon, 'spline');

% Compute the precise central difference
slope = (vol_up - vol_down) / (2 * epsilon);

end
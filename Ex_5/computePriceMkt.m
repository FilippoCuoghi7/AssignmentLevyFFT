function Call_Prices = computePriceMkt(S0, q, K, sigma, df_mat, ref_date, end_date)
% COMPUTE_PRICE_MKT Calculates European Call option prices using the Black-76 
% (Forward) formulation, vectorized across multiple strikes.
%
%   Inputs:
%       S0       : (Scalar) Spot price
%       q        : (Scalar) Continuous dividend yield 
%       K        : (Vector) Array of strike prices
%       sigma    : (Vector) Array of implied volatilities.                                       
%       df_mat   : The discount factor B(t0, T) from the reference date to maturity.
%       ref_date : The valuation date.
%       end_date : The maturity date of the options.
%
%   Output:
%       Call_Prices : Array of computed European Call option prices, matching  
%                     the dimensions of the input strikes vector.

% Calculate Time to Maturity (T) in years (Act/365)
T = yearfrac(ref_date, end_date, 3); 

% Calculate the ATM Forward Price (F0)
F0 = (S0 * exp(-q * T)) / df_mat;

% Calculate d1 and d2 (for all strikes simultaneously)
d1 = (log(F0 ./ K) + 0.5 * (sigma.^2) * T) ./ (sigma * sqrt(T));
d2 = d1 - sigma * sqrt(T);

% Calculate the Normal CDF for all d1 and d2
Nd1 = normcdf(d1);
Nd2 = normcdf(d2);

% Calculate all Call Prices at once
Call_Prices = df_mat * (F0 * Nd1 - K .* Nd2);
end
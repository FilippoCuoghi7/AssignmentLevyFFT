function [Correction, details] = computeCorrectionTerm(mkt_data, df_mat, ref_date, mat_date)
% COMPUTE_CORRECTION_TERM Calculates the smile adjustment (digital risk)
% for a digital option using the implied volatility slope and Vega.
%
% INPUTS:
%   mkt_data: Structure array containing the market dataset.
%   df_mat:   The exact interpolated discount factor at maturity B(t0, t).
%   ref_date: The initial valuation date of the contract.
%   mat_date: The maturity date of the option.
%
% OUTPUTS:
%   Correction: The scalar monetary value of the smile correction term.
%   details   : Struct containing variables for the report.

% Calculate Time to Maturity (T) in years (Act/365)
T = yearfrac(ref_date, mat_date, 3);

% Extract market parameters and compute the implied volatility slope
[F0, sigma, Slope] = computeSlopeCorrectiveTerm(mkt_data, df_mat, ref_date, mat_date);

% Compute the Vega using the Black (1976) model
Vega = black76Vega(F0, F0, df_mat, sigma, T); % K = F0 since "ATM Fwd"

% Compute the final Correction Term
Correction = Slope * Vega;

% Details for the report
details = struct();

details.Slope = Slope;
details.Vega = Vega;

end
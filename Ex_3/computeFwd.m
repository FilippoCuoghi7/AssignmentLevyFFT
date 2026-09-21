function F0 = computeFwd(mkt_data, df_mat, ref_date, end_date)
% COMPUTE_FWD Calculates the ATM forward price of the stock extracting the 
% data from the dataset.
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
% OUTPUTS:
%   F0       : The extracted Fwd Price, which serves as the ATM anchor.



% Extract the Spot Price (S0) and dividend yield
S0 = mkt_data.cSelect.reference;
q = mkt_data.cSelect.dividends;

% Compute the yearfrac between start_date and end_date (ACT/365)
T = yearfrac(ref_date, end_date, 3);

% Compute Fwd price
F0 = S0 * exp(- q * T)/df_mat;

end
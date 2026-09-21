function Call_Price = computeCallPrice(F0, df_mat, int_val, x)
% COMPUTE_CALL_PRICE Calculates the European Call option price using the
% Lewis (2001) formula, given a pre-computed integral and a specific log-moneyness.
%
% INPUTS:
%   F0      : Forward price of the underlying asset.
%   df_mat  : Discount factor from maturity to start_date B(t0, t).
%   int_val : The numerically computed integral.
%   x       : The log-moneyness of the option, defined as ln(F0 / K).
%
% OUTPUTS:
%   Call_Price : The scalar computed price of the European Call option.

% Assemble the final Lewis price
% We use real() to drop any microscopic imaginary residual from the numerical integration
Call_Price = df_mat * F0 .* (1 - exp(-x./2) .* real(int_val));

end
function [MC_Coupon, Call_MC, MC_Error] = computeCouponMC(Nsim, alpha, T, df, weights, strike, d1, d2, rho, sigma1, sigma2, notional)
% COMPUTECOUPONMC Prices an Arithmetic Basket Call Option using Monte Carlo
% Simulations and Cholesky decomposition for the correlation.
%
% Inputs:
%   Nsim     : Number of Monte Carlo simulations to run
%   alpha    : Participation coefficient
%   T        : Time to maturity (in years)
%   df       : Exact discount factor from maturity to present
%   weights  : 2-element vector containing the weights of the two assets
%   strike   : Strike level of the basket option
%   d1, d2   : Continuous dividend yields of asset 1 and asset 2
%   rho      : Correlation coefficient between the two assets
%   sigma1   : Implied volatility of asset 1
%   sigma2   : Implied volatility of asset 2
%   notional : The Principal Amount of the contract
%
% Outputs:
%   MC_Coupon: Final monetary value of the coupon payment
%   Call_MC  : Discounted expected price of the Call option
%   MC_Error : Standard error of the Monte Carlo price estimate

% Ensure it's a column vector
w = weights(:);

% Normalized starting prices for the index/basket calculation
S0_1 = 1;
S0_2 = 1;

% Compute the scalar continuous risk-free rate
r = -log(df) / T;

% Draw Nsim independent standard normal random variables
Z1 = randn(Nsim, 1);
Z2 = randn(Nsim, 1);

% Apply Cholesky decomposition for the correlation
W1 = Z1;
W2 = rho * Z1 + sqrt(1 - rho^2) * Z2;
% Now, W1 and W2 have exactly rho correlation.

% Simulate the Asset Prices using the exact solution to the Geometric Brownian Motion SDE
S1_T = S0_1 * exp((r - d1 - 0.5 * sigma1^2) * T + sigma1 * sqrt(T) .* W1);
S2_T = S0_2 * exp((r - d2 - 0.5 * sigma2^2) * T + sigma2 * sqrt(T) .* W2);

% The basket value is the weighted sum of the two terminal prices
Basket_T = w(1) * S1_T + w(2) * S2_T;

% Compute Call Payoff
payoffs = max(Basket_T - strike, 0);

% The price is the discounted average of all simulated payoffs
Call_MC = df * mean(payoffs);

% Compute the standard error of the Monte Carlo simulation, scaled to EUR
MC_Error = notional * alpha * df * std(payoffs) / sqrt(Nsim);

% Compute Final Coupon Payment
MC_Coupon = notional * alpha * Call_MC;

end
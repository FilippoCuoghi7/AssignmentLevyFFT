function [df, Coupon, details] = computeCouponMomentMatching(alpha, start_date, ...
    end_date, dates, discounts, weights, strike, d1, d2, rho, sigma1, sigma2, notional)
% COMPUTECOUPONMOMENTMATCHING Calculates the final monetary payoff of a
% European Call on an arithmetic two-asset basket using Moment Matching
% (The Levy Approximation).
%
% Inputs:
%   alpha    : Participation coefficient
%   start_date : Start date of the certificate
%   end_date : Maturity date of the certificate
%   dates    : Dates of the bootstrapped discount curve
%   discounts: Discount factors of the bootstrapped curve
%   weights  : 2-element vector containing the weights of the two assets
%   strike   : Strike level of the basket option (the protection level)
%   d1, d2   : Continuous dividend yields of asset 1 and asset 2
%   rho      : Correlation coefficient between the two assets
%   sigma1   : Implied volatility of asset 1
%   sigma2   : Implied volatility of asset 2
%   notional : The Principal Amount of the contract
%
% Outputs:
%   df       : Interpolated discount factor at the maturity date
%   Coupon   : Final monetary value of the coupon payment
%   details  : Struct with the intermediate moment-matching quantities
%              (basket forward, second moment, synthetic basket vol) used
%              for the report

% Ensure weights is a column vector
w = weights(:);

% Normalized starting value of the assets
S0_1 = 1;
S0_2 = 1;

% Calculate Time to Maturity (T) in years (Act/365)
T = yearfrac(start_date, end_date, 3);

% Extract the exact interpolated discount factor for the maturity date
df = getDiscountFactorByZeroRatesLinearInterp(start_date, end_date, dates, discounts);

% Compute the scalar continuous risk-free rate
r = -log(df) / T;

% Compute Fwd's
F1 = S0_1 * exp((r - d1) * T);
F2 = S0_2 * exp((r - d2) * T);

% First Moment (Expected value of the sum)
M1 = w(1)*F1 + w(2)*F2;

% Second Moment (Expected value of the sum squared)
M2 = (w(1)^2 * F1^2 * exp(sigma1^2 * T)) + ...
    (w(2)^2 * F2^2 * exp(sigma2^2 * T)) + ...
    (2 * w(1) * w(2) * F1 * F2 * exp(rho * sigma1 * sigma2 * T));

% Implied Lognormal Volatility of the Basket
sigma_basket = sqrt( (1/T) * log(M2 / (M1^2)) );

% Using M1 as the Forward Price of the basket
d1_bs = (log(M1 / strike) + 0.5 * sigma_basket^2 * T) / (sigma_basket * sqrt(T));
d2_bs = d1_bs - sigma_basket * sqrt(T);

% Call Price using Black
Call_Price = df * (M1 * normcdf(d1_bs) - strike * normcdf(d2_bs));

% Final Payoff
Coupon = notional * alpha * Call_Price;

% Details for the report
details = struct();
details.M1_Forward = M1;
details.M2_SecondMoment = M2;
details.sigma_basket = sigma_basket;
details.coupon_price = Coupon;

end
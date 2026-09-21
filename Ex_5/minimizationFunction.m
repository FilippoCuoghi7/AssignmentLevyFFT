function d = minimizationFunction(p, alpha, dt, F0, df_mat, x, CallPricesMkt, weigths)
% MINIMIZATIONFUNCTION Computes the sum of squared errors between market
% Call prices and model Call prices for global calibration.
%
%   Inputs:
%       p             : (Vector) The 3 optimizer guesses: [sigma, kappa, eta]
%       alpha         : Tempered Stable parameter
%       dt            : Time to maturity (T - t0)
%       F0            : ATM Forward price
%       df_mat        : Discount factor B(t0, T)
%       x             : (Vector) Log-moneyness array for all strikes
%       CallPricesMkt : (Vector) The actual market Call prices
%       weigths       : (Vector) Calibration weights
%
%   Output:
%       d             : The sum of squared errors (or a massive
%                       penalty if constraints are violated).

% Unpack parameters
sigma = p(1);
kappa = p(2);
eta   = p(3);

% Safety Check
if sigma <= 1e-4 || kappa <= 1e-4
    d = 1e12;
    return;
end

% Calculate the boundary.
w_bar = (1 - alpha) / (kappa * sigma^2);
if eta <= -w_bar
    d = 1e12;
    return;
end

% Build Characteristic Function
phi = buildCharFunG(sigma, kappa, eta, dt, alpha);

% Compute Model Prices via Quadrature
Lewis_integral = zeros(length(x), 1);

for j = 1:length(x)
    scalar_integrand = computeIntegrandLewis(x(j), phi);
    Lewis_integral(j) = quadgk(scalar_integrand, -Inf, Inf);
end

CallPricesModel = computeCallPrice(F0, df_mat, Lewis_integral, x);

% Compute Error
d = sum(weigths .* (CallPricesModel - CallPricesMkt).^2);

end
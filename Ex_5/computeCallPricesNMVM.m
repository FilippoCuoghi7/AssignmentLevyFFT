function CallPrices = computeCallPricesNMVM(p, alpha, F0, df_mat, dt, x)
% COMPUTECALLPRICESNMVM Computes the Call Prices under NMVM model using 
% the parameters retrieved from the Minimization Problem.
%
%   Inputs:
%       p             : (Vector) The 3 optimizer guesses: [sigma, kappa, eta]
%       alpha         : Tempered Stable parameter
%       dt            : Time to maturity (T - t0)
%       F0            : ATM Forward price
%       df_mat        : Discount factor B(t0, T)
%       x             : (Vector) Log-moneyness array for all strikes
%
%  Output:
%       CallPrices    : (Vector) The prices of the Call Options using the
%       above parameters, in function of the Log-moneyness array.


% Unpack parameters
sigma = p(1);
kappa = p(2);
eta   = p(3);

% Safety Check
if sigma <= 1e-4 || kappa <= 1e-4
    CallPrices = 1e12;
    return;
end

% Calculate the boundary
w_bar = (1 - alpha) / (kappa * sigma^2);
if eta <= -w_bar
    CallPrices = 1e12;
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

CallPrices = computeCallPrice(F0, df_mat, Lewis_integral, x);

end
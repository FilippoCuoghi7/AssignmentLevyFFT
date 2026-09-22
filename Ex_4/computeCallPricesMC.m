function CallPricesMC = computeCallPricesMC(Nsim, sigma, eta, kappa, dt, F0, df_mat, x, alpha)
% COMPUTECALLPRICESMC Prices European Call options under a Normal Mean-Variance
% Mixture (NMVM) model using a Monte Carlo simulation.
%
% -------------------------------------------------------------------------
% INPUTS:
%   Nsim         : Number of Monte Carlo simulation paths.
%   sigma        : Volatility parameter of the model.
%   eta          : Skewness/Asymmetry parameter of the model.
%   kappa        : Variance parameter of the market time subordinator.
%   dt           : Time to maturity (in years).
%   F0           : Forward price of the underlying asset at maturity.
%   df_mat       : Discount factor from maturity to today.
%   x            : (Vector) Log-moneyness values (x = ln(F0/K)).
%   alpha        : Tail heaviness parameter.
%
% OUTPUTS:
%   CallPricesMC : (Vector) Discounted expected Call option prices
%                  corresponding exactly to the strikes implied by x.

% Define the inner argument of the Laplace transform
inner_arg = @(xi) (xi.^2 + 1i .* (1 + 2*eta) .* xi) ./ 2;

% Define the Log-Laplace function
ln_L = @(w) (dt / kappa) * (1-alpha)/alpha .* (1 - (1 + (kappa .* sigma^2 .* w)./(1-alpha)).^alpha);

% Evaluate the Log-Laplace transform at -i to get the drift correction
drift_correction = ln_L(inner_arg(-1i));

% SIMULATE MARKET TIME (THE SUBORDINATOR)
% Define Inverse Gaussian parameters
mu_IG     = 1;
lambda_IG = dt / kappa;  % Derived from Var = mu^3/lambda = kappa/dt

% Draw Nsim paths for normalized market speed
G = random('InverseGaussian', mu_IG, lambda_IG, Nsim, 1);

% Convert normalized speed into Absolute Market Time elapsed
G_absolute = G * dt;

% SIMULATE TERMINAL STOCK PRICES (using Anthitetic Variable technique)
N_half = floor(Nsim / 2);
g_half = randn(N_half, 1);
g = [g_half; -g_half];

% Add with one extra draw if Nsim is an odd number
if length(g) < Nsim
    g = [g; randn(1, 1)];
end

% Construct the simulated log-return path (ft)
fT = -drift_correction + sigma .* sqrt(G_absolute) .* g - sigma^2 * (0.5 + eta) .* G_absolute;

% Force the average of the simulated exponentials to perfectly match F0
% (Empirical Martingale Correction)
empirical_mean = mean(exp(fT));
FT = F0 .* (exp(fT) / empirical_mean);

% Convert log-moneyness grid back to actual Strike prices
Strikes = F0 * exp(-x);

% Implicit expansion creates a massive (Nsim x M) matrix of all payoffs instantly
payoffs = max(FT - Strikes(:)', 0);

% Average each column (dimension 1), discount it, and transpose back to a
% column vector to get the prices of the Calls for different strikes (i.e. log-moneynesses).
CallPricesMC = df_mat * mean(payoffs, 1)';
CallPricesMC = CallPricesMC';

end
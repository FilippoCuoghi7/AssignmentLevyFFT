function phi = buildCharFunG(sigma, kappa, eta, dt, alpha)
% BUILDCHARFUNG Constructs the characteristic function for the
% Tempered Stable Subordinator model.
%
%   Inputs:
%       sigma, kappa, eta : The three model parameters
%       dt                : Time to maturity
%       alpha             : The paramater which characterizes the Tempered Stable model
%
%   Output:
%       phi               : A function handle for the characteristic function of Log-Returns

% Define the inner argument of the Laplace transform
inner_arg = @(xi) (xi.^2 + 1i .* (1 + 2*eta) .* xi) ./ 2;

% Define the Log-Laplace function
ln_L = @(w) (dt / (kappa)) * (1-alpha)/alpha .* (1 - (1 + (kappa .* sigma^2 .* w)./(1-alpha)).^(alpha));

% Evaluate the Log-Laplace transform at -i to get the drift correction
drift_correction = ln_L( inner_arg(-1i));

% Build the final Characteristic Function handle of the Log-Returns
phi = @(xi) exp( -1i .* xi .* drift_correction + ln_L(inner_arg(xi)) );

end
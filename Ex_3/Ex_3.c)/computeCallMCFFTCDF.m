function Call_Price_IndirectMC = computeCallMCFFTCDF(Nsim, f, F0, B, M, x1, z1, dz, x)
% CALL_PRICE_INDIRECTMC Prices a European Call using Monte Carlo (indirectly), 
% building the CDF numerically via the FFT Digital pricing method.
%
%   Inputs:
%       Nsim : number of Monte Carlo simulations
%       f    : characteristic function handle phi(z)
%       F0   : ATM forward
%       B    : discount factor df_mat
%       M, x1, z1, dz : FFT parameters for the digital pricer
%       x    : log-moneyness of the Call options, x = log(F0/K) (Row vector)
%
%   Output:
%       Call_Price_IndirectMC : Vector of Call prices

% Build the Target Grid of possible logReturns at maturity.
y_grid = linspace(-20, 20, 20000);

% Compute the Digital Prices (flip the sign)
eval_x = -y_grid;
D_grid = priceDigitalFFT(f, eval_x, B, M, x1, z1, dz);

% Convert Digital Prices to the CDF
% F(y) = 1 - D(-y)/B
cdf_grid = 1 - (D_grid ./ B);

% Data Cleanup (cap probabilities exactly between 0 and 1)
cdf_grid = max(min(cdf_grid, 1), 0);

% Extract only unique points ('interp1' requires the x-axis point, here the
% cdf points, to be unique).
[cdf_unique, unique_idx] = unique(cdf_grid);
y_unique = y_grid(unique_idx);

% Inverse Transform (MC standard)

% Generate Uniform Random Numbers U ~ (0,1)
U = rand(Nsim, 1); % probabilities.

% Map U's backwards to find simulated log-returns (y_sim)
y_sim = interp1(cdf_unique, y_unique, U, 'linear');

% Compute the Call payoff
x_row = x(:)';
payoffs = max(exp(y_sim) - exp(-x_row), 0);

% Compute the Call price
Call_Price_IndirectMC = B * F0 * mean(payoffs, 1);

end
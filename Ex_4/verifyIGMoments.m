function [EmpMoments, TheoMoments] = verifyIGMoments(Nsim, kappa, dt)
% VERIFYIGMOMENTS Simulates an Inverse Gaussian subordinator and compares
% its first four empirical moments against the analytical theoretical moments.
%
% INPUTS:
%   Nsim  : Number of paths to simulate
%   kappa : Variance parameter of the subordinator
%   dt    : Time to maturity (in years)
%
% OUTPUTS:
%   EmpMoments  : [Mean, Variance, Skewness, Excess Kurtosis]
%                 calculated directly from the simulated data.
%   TheoMoments : [Mean, Variance, Skewness, Excess Kurtosis]
%                 calculated from the analytical mathematical formulas.

% Simulate Inverse Gamma Subordinator 
mu_IG     = 1;
lambda_IG = dt / kappa;

G_sim = random('InverseGaussian', mu_IG, lambda_IG, Nsim, 1);

% Compute Empirical Moments
emp_mean = mean(G_sim);
emp_var  = var(G_sim);
emp_skew = skewness(G_sim);

% MATLAB's kurtosis() calculates Pearson kurtosis (Normal dist = 3).
% We subtract 3 to get "Excess Kurtosis" to match the standard formula.
emp_kurt = kurtosis(G_sim) - 3;

EmpMoments = [emp_mean, emp_var, emp_skew, emp_kurt];

% Compute Theoretical Moments
theo_mean = 1;
theo_var  = kappa / dt;
theo_skew = 3 * sqrt(kappa / dt);
theo_kurt = 15 * (kappa / dt);

TheoMoments = [theo_mean, theo_var, theo_skew, theo_kurt];

% Print of the Comparison
fprintf('\n======================================================\n');
fprintf('   INVERSE GAUSSIAN MOMENT VERIFICATION (N = %d)\n', Nsim);
fprintf('======================================================\n');
fprintf('%-15s | %-15s | %-15s\n', 'Moment', 'Theoretical', 'Empirical (MC)');
fprintf('----------------|-----------------|-------------------\n');
fprintf('%-15s | %-15.6f | %-15.6f\n', '1. Mean', theo_mean, emp_mean);
fprintf('%-15s | %-15.6f | %-15.6f\n', '2. Variance', theo_var, emp_var);
fprintf('%-15s | %-15.6f | %-15.6f\n', '3. Skewness', theo_skew, emp_skew);
fprintf('%-15s | %-15.6f | %-15.6f\n', '4. Exc. Kurtosis', theo_kurt, emp_kurt);
fprintf('======================================================\n\n');

end
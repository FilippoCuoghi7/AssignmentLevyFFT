function plotCdfReconstruction(f, F0, B, M, x1, z1, dz, Nsim, titleStr, seedVal)
% PLOTCDFRECONSTRUCTION Reconstructs and plots the CDF of the terminal
% log-return from FFT-priced digitals (same construction used internally
% by computeCallMCFFTCDF), then validates it against the empirical CDF of
% inverse-transform-sampled draws.
%
% Inputs:
%   f             : characteristic function handle phi(z)
%   F0            : ATM forward
%   B             : discount factor df_mat
%   M,x1,z1,dz    : FFT parameters for the digital pricer (pass [] for the
%                   one not fixed, matching computeIntegralFFT's convention)
%   Nsim          : number of samples to draw for the empirical-CDF check
%   titleStr      : string used in figure titles (e.g. 'Double Exponential')
%   seedVal       : RNG seed for reproducibility

rng(seedVal, 'twister');

% Build the target grid and reconstruct the CDF
y_grid = linspace(-20, 20, 20000);
eval_x = -y_grid;
D_grid = priceDigitalFFT(f, eval_x, B, M, x1, z1, dz);
cdf_grid = 1 - (D_grid ./ B);
cdf_grid = max(min(cdf_grid, 1), 0);
[cdf_unique, unique_idx] = unique(cdf_grid);
y_unique = y_grid(unique_idx);

% --- Figure 1: reconstructed CDF ---
figure('Name', ['Reconstructed CDF - ' titleStr], 'Color', 'w');
plot(y_unique, cdf_unique, 'b-', 'LineWidth', 1.5);
grid on;
xlim([-10, 10]);
xlabel('X = log(F_t / F_0)');
ylabel('F_X(X)');
title(['Reconstructed CDF of X = log(F_t/F_0), ' titleStr ' model']);

% --- Figure 2: empirical vs target CDF (validation) ---
U = rand(Nsim, 1);
y_sim = interp1(cdf_unique, y_unique, U, 'linear');
y_sorted = sort(y_sim);
f_emp = ((1:Nsim)' - 0.5) / Nsim;

figure('Name', ['CDF Check - ' titleStr], 'Color', 'w');
plot(y_sorted, f_emp, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Empirical CDF from simulations');
hold on;
plot(y_unique, cdf_unique, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Target CDF');
grid on;
xlim([-10, 10]);
xlabel('X = log(F_t / F_0)');
ylabel('CDF');
title(['Empirical vs Target CDF, ' titleStr ' model']);
legend('Location', 'best');
hold off;

end

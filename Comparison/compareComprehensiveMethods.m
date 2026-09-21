function compareComprehensiveMethods(x, Call_Res, Call_Quad, Call_MC, Call_FFT, titleStr)
% COMPARECOMPREHENSIVEMETHODS Benchmarks all numerical methods against the
% analytical solution (Residuals).
%
% INPUTS:
%   x        : Log-moneyness grid ln(F0/K).
%   Call_Res : Analytical Prices (Residuals).
%   Call_Quad: Adaptive Quadrature Prices (QuadGK).
%   Call_MC  : Monte Carlo Prices (Direct or Indirect).
%   Call_FFT : FFT Prices.
%   titleStr : Title for report and plots.

% Ensure column vectors
x = x(:);
pR = Call_Res(:);
pQ = Call_Quad(:);
pM = Call_MC(:);
pF = Call_FFT(:);

% Calculate absolute errors relative to the Analytical Solution (Residuals)
errQ = abs(pQ - pR);
errM = abs(pM - pR);
errF = abs(pF - pR);

% Reporting
sep = repmat('=', 1, 70);
fprintf('\n%s\n', sep);
fprintf(' COMPREHENSIVE METHOD COMPARISON: %s\n', titleStr);
fprintf(' (Reference: Analytical Residuals)\n');
fprintf('%s\n', repmat('-', 1, 70));

% Create comparison table
T = table(x, pR, pQ, pM, pF, 'VariableNames', ...
    {'LogMoneyness', 'Residuals_Ref', 'QuadGK', 'MonteCarlo', 'FFT'});
disp(T);

fprintf('MAXIMUM ERRORS vs. ANALYTICAL SOLUTION:\n');
fprintf('  >> Max Error QuadGK: %.4e\n', max(errQ));
fprintf('  >> Max Error MC:     %.4e\n', max(errM));
fprintf('  >> Max Error FFT:    %.4e\n', max(errF));
fprintf('%s\n\n', sep);

% Visualization
figure('Name', ['Comprehensive Analysis: ', titleStr], 'Color', 'w', 'Position', [100, 100, 1100, 500]);

% Subplot 1: Price Curves
subplot(1, 2, 1);
plot(x, pR, 'k-', 'LineWidth', 3, 'DisplayName', 'Analytical (Ref)'); hold on;
plot(x, pQ, 'g--', 'LineWidth', 1.5, 'DisplayName', 'QuadGK');
plot(x, pF, 'r:', 'LineWidth', 2, 'DisplayName', 'FFT');
plot(x, pM, 'b.', 'MarkerSize', 12, 'DisplayName', 'Monte Carlo');
grid on; box on;
xlabel('Log-moneyness $x = \ln(F_0/K)$', 'Interpreter', 'latex', 'FontSize', 11);
ylabel('Option Price', 'FontSize', 11);
title(['\textbf{Price Comparison: ', titleStr, '}'], 'Interpreter', 'latex', 'FontSize', 13);
legend('Location', 'best');

% Subplot 2: Convergence Errors
subplot(1, 2, 2);
semilogy(x, errQ, 'g-^', 'LineWidth', 1.2, 'MarkerFaceColor', 'g', 'DisplayName', 'QuadGK Error'); hold on;
semilogy(x, errF, 'r-s', 'LineWidth', 1.2, 'MarkerFaceColor', 'r', 'DisplayName', 'FFT Error');
semilogy(x, errM, 'b-o', 'LineWidth', 1.2, 'MarkerFaceColor', 'b', 'DisplayName', 'MC Error');

% Reference line for 1-cent precision (Standard Market Tolerance)
yline(1e-2, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'HandleVisibility', 'off');

grid on; box on;
set(gca, 'YMinorGrid', 'on', 'TickLabelInterpreter', 'latex');
xlabel('Log-moneyness $x$', 'Interpreter', 'latex', 'FontSize', 11);
ylabel('Abs Error vs. Residuals (Log)', 'FontSize', 11);
title('\textbf{Numerical Convergence Hierarchy}', 'Interpreter', 'latex', 'FontSize', 13);
legend('Location', 'southoutside', 'Orientation', 'horizontal');

end
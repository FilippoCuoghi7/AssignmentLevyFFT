function compareMCVarieties(x, Call_Direct, Call_Indirect, titleStr)
% COMPAREMCVARIETIES Compares Direct and Indirect Monte Carlo pricing.
%
% INPUTS:
%   x             : Log-moneyness grid.
%   Call_Direct   : Prices from direct distribution sampling.
%   Call_Indirect : Prices from Inverse CDF (FFT-based) sampling.
%   titleStr      : Title for report and plots.

% Ensure column vectors
x = x(:);
pD = Call_Direct(:);
pI = Call_Indirect(:);
diff_mc = abs(pD - pI);

% Reporting
fprintf('\n======================================================\n');
fprintf(' MONTE CARLO VARIETY CHECK: %s\n', titleStr);
fprintf('======================================================\n');
T = table(x, pD, pI, diff_mc, 'VariableNames', ...
    {'LogMoneyness', 'MC_Direct', 'MC_Indirect', 'Abs_Difference'});
disp(T);
fprintf('Max Discrepancy between MC Methods: %.4e\n', max(diff_mc));
fprintf('======================================================\n\n');

% Visualization
figure('Name', ['MC Comparison: ', titleStr], 'Color', 'w');

% Subplot 1: Price Curves
subplot(1,2,1);
plot(x, pD, 'b-o', 'LineWidth', 1.5, 'DisplayName', 'MC Direct'); hold on;
plot(x, pI, 'c--s', 'LineWidth', 1.5, 'DisplayName', 'MC Indirect');
grid on; xlabel('Log-moneyness $x$'); ylabel('Price');
title('MC Prices Comparison'); legend('Location','best');

% Subplot 2: Convergence Errors
subplot(1,2,2);
semilogy(x, diff_mc, 'k-d', 'MarkerFaceColor', 'k', 'DisplayName', '|Direct - Indirect|');
grid on; xlabel('Log-moneyness $x$'); ylabel('Difference (Log Scale)');
title('Statistical Discrepancy');
end
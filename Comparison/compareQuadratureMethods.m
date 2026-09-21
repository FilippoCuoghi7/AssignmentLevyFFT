function compareQuadratureMethods(x, Call_Rect, Call_Trapz, Call_Quad, titleStr)
% COMPAREQUADRATUREMETHODS Evaluates the precision of fixed-grid numerical
% integration methods (Rectangular and Trapezoidal) against an adaptive
% benchmark (QuadGK).
%
% INPUTS:
%   x          : Log-moneyness grid.
%   Call_Rect  : Prices via Rectangular (Midpoint) rule.
%   Call_Trapz : Prices via Trapezoidal rule.
%   Call_Quad  : Benchmark Prices via QuadGK.
%   titleStr   : Title for report and plots.

% Ensure column vectors
x = x(:);
pR = Call_Rect(:);
pT = Call_Trapz(:);
pQ = Call_Quad(:);

% Calculate errors relative to the adaptive benchmark
errRect  = abs(pR - pQ);
errTrapz = abs(pT - pQ);

% Reporting
fprintf('\n======================================================\n');
fprintf(' QUADRATURE VARIETY CHECK: %s\n', titleStr);
fprintf('======================================================\n');
T = table(x, pQ, pR, pT, 'VariableNames', ...
    {'LogMoneyness', 'QuadGK_Ref', 'Rectangular', 'Trapezoidal'});
disp(T);
fprintf('Max Discrepancy Rect vs QuadGK:  %.4e\n', max(errRect));
fprintf('Max Discrepancy Trapz vs QuadGK: %.4e\n', max(errTrapz));
fprintf('======================================================\n\n');

% Visualization
figure('Name', ['Quadrature Comparison: ', titleStr], 'Color', 'w', 'Position', [100, 100, 1000, 450]);

% Subplot 1: Price Curves
subplot(1, 2, 1);
plot(x, pQ, 'k-', 'LineWidth', 2, 'DisplayName', 'QuadGK (Ref)'); hold on;
plot(x, pR, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'Rectangular');
plot(x, pT, 'b--s', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'Trapezoidal');
grid on;
xlabel('Log-moneyness $x$'); ylabel('Price');
title('Quadrature Prices Comparison');
legend('Location', 'best');

% Subplot 2: Convergence Errors
subplot(1, 2, 2);
semilogy(x, errRect, 'r-o', 'MarkerFaceColor', 'r', 'MarkerSize', 4, 'DisplayName', '|Rect - QuadGK|'); hold on;
semilogy(x, errTrapz, 'b-s', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'DisplayName', '|Trapz - QuadGK|');
grid on;
xlabel('Log-moneyness $x$'); ylabel('Error (Log Scale)');
title('Convergence Errors');
legend('Location', 'best');

end
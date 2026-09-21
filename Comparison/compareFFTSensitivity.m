function compareFFTSensitivity(x, pricesFFT1, pricesFFT2, titleStr)
% COMPAREFFTSENSITIVITY Analyzes the difference between two FFT parameterizations.
%
% INPUTS:
%   x          : Log-moneyness grid
%   pricesFFT1 : FFT results using Case 1 (fixed x1)
%   pricesFFT2 : FFT results using Case 2 (fixed dz)
%   titleStr   : Title for the plots

% Ensure every vector is a column
x = x(:);
p1 = pricesFFT1(:);
p2 = pricesFFT2(:);

% Calculate the absolute difference between the two FFT methods
diff_fft = abs(p1 - p2);
max_diff = max(diff_fft);

% Reporting
sep = repmat('=', 1, 60);
fprintf('\n%s\n', sep);
fprintf(' FFT SENSITIVITY REPORT: %s\n', titleStr);
fprintf('%s\n', repmat('-', 1, 60));

% Sample Table (Every 10th row)
idx = 1:10:length(x);
T = table(x(idx), p1(idx), p2(idx), diff_fft(idx), ...
    'VariableNames', {'LogMoneyness', 'FFT_Case1', 'FFT_Case2', 'Abs_Difference'});
disp(T);

fprintf('MAXIMUM DISCREPANCY BETWEEN FFT METHODS:\n');
fprintf('  >> Max |FFT1 - FFT2|: %.4e\n', max_diff);
fprintf('%s\n\n', sep);

% Visualization 
figure('Name', ['FFT Sensitivity: ', titleStr], 'Color', 'w', 'Position', [150, 150, 950, 450]);

% Subplot 1: Price Curves (Overlap check)
subplot(1, 2, 1);
% Plot FFT1 as a solid thick red line
plot(x, p1, 'r-', 'LineWidth', 2.5, 'DisplayName', 'FFT Case 1 (x1)'); hold on;
% Plot FFT2 as a green dashed line (reveals the red underneath)
plot(x, p2, 'g--', 'LineWidth', 1.5, 'DisplayName', 'FFT Case 2 (dz)');
grid on; box on;
xlabel('Log-moneyness $x$', 'Interpreter', 'latex');
ylabel('Option Price', 'Interpreter', 'latex');
title(['\textbf{Prices: ', titleStr, '}'], 'Interpreter', 'latex');
legend('Location', 'best');

% Subplot 2: The Difference (Log Scale)
subplot(1, 2, 2);
semilogy(x, diff_fft, 'm-p', 'MarkerSize', 5, 'MarkerFaceColor', 'm', 'DisplayName', '|FFT1 - FFT2|');
grid on; box on;
set(gca, 'YMinorGrid', 'on', 'TickLabelInterpreter', 'latex');
xlabel('Log-moneyness $x$', 'Interpreter', 'latex');
ylabel('Difference (Log Scale)', 'Interpreter', 'latex');
title('\textbf{Numerical Sensitivity}', 'Interpreter', 'latex');

% Adjust zoom automatically to see the full range of the difference
if max_diff > 0
    ylim([min(diff_fft(diff_fft>0))*0.1, max_diff*10]);
end
end
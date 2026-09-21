function comparePricingMethods(x, pricesFFT, pricesQuad, pricesMC, titleStr)
% COMPAREPRICINGMETHODS Displays a table, prints max errors, and creates
% visualizations for option pricing comparisons for the different pricing methods.
%
% INPUTS:
%   x         : Log-moneyness grid
%   pricesFFT : Prices from FFT
%   pricesQuad: Prices from Quadrature
%   pricesMC  : (Optional) Prices from Monte Carlo
%   titleStr  : Title for the plots

% Cleaning and Preparing
hasMC = (nargin >= 4) && ~isempty(pricesMC);
x = x(:);
pricesFFT = pricesFFT(:);
pricesQuad = pricesQuad(:);
if hasMC, pricesMC = pricesMC(:); end

% Calculate Errors (Reference: Quadrature)
errFFT = abs(pricesFFT - pricesQuad);
maxErrFFT = max(errFFT);

if hasMC
    errMC = abs(pricesMC - pricesQuad);
    maxErrMC = max(errMC);
end

% Reporting
sep = repmat('=', 1, 60);
fprintf('\n%s\n', sep);
fprintf(' COMPARISON REPORT: %s\n', titleStr);
fprintf('%s\n', repmat('-', 1, 60));

% Sample Table (Every 10th row)
idx = 1:10:length(x);
if hasMC
    T = table(x(idx), pricesQuad(idx), pricesFFT(idx), pricesMC(idx), ...
        'VariableNames', {'LogMoneyness', 'Quadrature', 'FFT', 'MonteCarlo'});
else
    T = table(x(idx), pricesQuad(idx), pricesFFT(idx), ...
        'VariableNames', {'LogMoneyness', 'Quadrature', 'FFT'});
end
disp(T);

% Numerical Error Summary
fprintf('MAXIMUM ABSOLUTE ERRORS:\n');
fprintf('  >> Max |FFT - Quad|: %.4e\n', maxErrFFT);
if hasMC
    fprintf('  >> Max |MC  - Quad|: %.4e\n', maxErrMC);
end
fprintf('%s\n\n', sep);

% Visualization
figure('Name', titleStr, 'Color', 'w', 'Units', 'normalized', 'Position', [0.1, 0.2, 0.8, 0.45]);

% Subplot 1: Price Curves
subplot(1, 2, 1);
plot(x, pricesQuad, 'k-', 'LineWidth', 2.5, 'DisplayName', 'Quadrature (Ref)'); hold on;
plot(x, pricesFFT, 'r--', 'LineWidth', 1.5, 'DisplayName', 'FFT');
if hasMC
    plot(x, pricesMC, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b', 'DisplayName', 'Monte Carlo');
end
grid on; box on;
xlabel('Log-moneyness $x = \ln(F_0/K)$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Option Price', 'Interpreter', 'latex', 'FontSize', 12);
title(['\textbf{Prices: ', titleStr, '}'], 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best', 'FontSize', 10);

% Subplot 2: Convergence Errors
subplot(1, 2, 2);
semilogy(x, errFFT, 'r-s', 'MarkerSize', 4, 'MarkerFaceColor', 'r', 'LineWidth', 1.2, 'DisplayName', '|FFT - Quad|'); hold on;

if hasMC
    semilogy(x, errMC, 'b-d', 'MarkerSize', 4, 'MarkerFaceColor', 'b', 'LineWidth', 1.2, 'DisplayName', '|MC - Quad|');
    % Baseline for "Good" MC Precision (10^-2)
    yline(1e-2, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'HandleVisibility', 'off');
end

grid on; box on;
set(gca, 'YMinorGrid', 'on', 'TickLabelInterpreter', 'latex');
xlabel('Log-moneyness $x$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Absolute Error (Log Scale)', 'Interpreter', 'latex', 'FontSize', 12);
title('\textbf{Numerical Convergence}', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 10);
end


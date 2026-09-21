function plotImpliedVolModelVSMkt(MktVol, ModelVol, LogMon)
% IMPLIEDVOL_MODELVSMKT Plots the Market Implied Volatility against the
% Model Implied Volatility to visualize the calibration fit (the "Smile").
%
%   Inputs:
%       MktVol   : (Vector) Array of observed market implied volatilities.
%       ModelVol : (Vector) Array of calibrated model-implied volatilities.
%       LogMon   : (Vector) Array of the log-moneynesses (independent variable).


figure('Name', 'Implied Volatility Smile', 'Color', 'w');

% Plot Market Data 
plot(LogMon, MktVol * 100, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6, 'DisplayName', 'Market Data');
hold on;

% Plot Model Data
plot(LogMon, ModelVol * 100, 'r-', 'LineWidth', 2, 'DisplayName', 'Calibrated Model');

% Format the chart
grid on;
title('Implied Volatility Smile: Market vs. Model Calibration');
ylabel('Implied Volatility');
xlabel('Log-Moneyness (ln(F0/K))');
legend('Location', 'best');
hold off;

end
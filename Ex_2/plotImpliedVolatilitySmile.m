function plotImpliedVolatilitySmile(mkt_data, details_Corr, df_mat, ref_date, end_date)
% PLOT_IMPLIEDVOLATILITY_SMILE Generates a professional plot of the 1-year
% implied volatility smile, highlighting the ATM Spot and its tangent line.
%
% INPUTS:
%   mkt_data     : Structure array containing the market dataset. Must contain
%                  the nested struct 'cSelect' with the 'strikes', 'surface'
%                  (volatilities), and 'reference' (S0) fields.
%   details_Corr : Structure containing the smile correction details,
%                  specifically the calculated 'Slope' (dSigma/dK) at S0.
%   df_mat       : The discount from the reference date up to the maturity date.
%   ref_date     : The starting date of the contract.
%   end_date     : The maturity date of the contract.

% Extract market parameters
strikes = mkt_data.cSelect.strikes;
vols_1y = mkt_data.cSelect.surface;
S0      = mkt_data.cSelect.reference;
q = mkt_data.cSelect.dividends;

% Initialize the figure
figure('Name', 'Implied Volatility Smile', 'Color', 'w');

% Plot the main volatility curve (scaled to percentage)
plot(strikes, vols_1y * 100, '-o', 'LineWidth', 1.5, 'MarkerSize', 5, 'Color', [0 0.4470 0.7410]);
hold on;

% Compute the yearfrac between start_date and end_date (ACT/365)
T = yearfrac(ref_date, end_date, 3);

% Compute Fwd price
F0 = S0 * exp(- q * T)/df_mat;

% Highlight the ATM Fwd (F0) anchor
[~, idx_F0] = min(abs(strikes - F0));
vol_F0 = vols_1y(idx_F0);

plot(F0, vol_F0 * 100, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

% Compute and plot the tangent line representing the local slope
slope_pct = details_Corr.Slope * 100;
tangent_line = (vol_F0 * 100) + slope_pct * (strikes - F0);

plot(strikes, tangent_line, '--k', 'LineWidth', 1.2);

grid on;
title('Market Implied Volatility Smile (1-Year Expiry)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Strike Price (EUR)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Implied Volatility (%)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Implied Volatility Curve', 'ATM Fwd Anchor (F0)', 'Local Tangent (Smile Risk)', ...
    'Location', 'best', 'FontSize', 11);

% Constrain the X-axis tightly to the available strike data
% xlim([min(strikes), max(strikes)]);
hold off;

end
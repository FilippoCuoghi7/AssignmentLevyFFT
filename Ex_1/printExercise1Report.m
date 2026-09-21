function printExercise1Report(Principal, ref_date, mat_date, Protection, alpha, spread, rho, df_mat, BPV_f, coupon, X_perc, details_dates, details_coupon, X_percMC, MC_Error)
% PRINTEXERCISE1REPORT Prints a formatted valuation report for Ex 1.
%
% INPUTS:
%   Principal     : Contract Notional Amount.
%   ref_date      : Start Date.
%   mat_date      : Maturity Date.
%   Protection    : Protection level percentage.
%   alpha         : Participation coefficient.
%   spread        : Floating leg spread.
%   rho           : Correlation between assets.
%   df_mat        : Interpolated discount factor at maturity.
%   BPV_f         : Basis Point Value of the floater.
%   coupon        : Final monetary value of the Black-Scholes coupon.
%   X_perc        : The calculated Upfront percentage.
%   details_dates : Struct containing schedule details.
%   details_coupon: Struct containing basket calculation details.
%   X_percMC      : Upfront percentage from the Monte Carlo cross-check.
%   MC_Error      : Monte Carlo standard error on the coupon estimate.

fprintf('\n');
fprintf('============================================================\n');
fprintf('    EXERCISE 1: CERTIFICATE PRICING & UPFRONT CALCULATION\n');
fprintf('============================================================\n');
fprintf('Principal Amount (N)      : EUR %15.2f\n', Principal);
fprintf('Start Date                : %19s\n', datestr(ref_date, 'dd-mmm-yyyy'));
fprintf('Maturity Date             : %19s\n', datestr(mat_date, 'dd-mmm-yyyy'));
fprintf('Protection Level (P)      : %15.2f %%\n', Protection * 100);
fprintf('Participation (alpha)     : %15.2f %%\n', alpha * 100);
fprintf('Euribor Spread            : %15.2f bps\n', spread * 10000);
fprintf('Correlation (rho)         : %15.2f %%\n', rho * 100);
fprintf('------------------------------------------------------------\n');
fprintf('--- Basket & Option Parameters (Moment Matching) ---\n');
fprintf('Synthetic Basket Vol      : %15.2f %%\n', details_coupon.sigma_basket * 100);
fprintf('Total Payment Periods     : %15d\n', details_dates.num_periods);
fprintf('------------------------------------------------------------\n');
fprintf('--- Valuation Components ---\n');
fprintf('Discount Factor @ Maturity: %15.6f\n', df_mat);
fprintf('BPV Floater               : %15.6f\n', BPV_f);
fprintf('Coupon Value (Party B)    : EUR %15.2f\n', coupon);
fprintf('============================================================\n');
fprintf('>>> FINAL UPFRONT (X%%)    : %15.4f %%\n', X_perc * 100);
fprintf('>>> UPFRONT AMOUNT        : EUR %15.2f\n', X_perc * Principal);
fprintf('============================================================\n');
fprintf('--- Monte Carlo Cross-Check ---\n');
fprintf('MC Upfront (X%%)           : %15.4f %%\n', X_percMC * 100);
fprintf('Closed-Form vs MC Diff    : %15.4f %% (%.2f bps)\n', ...
    (X_perc - X_percMC) * 100, (X_perc - X_percMC) * 10000);
fprintf('MC Standard Error (Coupon): EUR %15.2f\n', MC_Error);
fprintf('============================================================\n\n');

% Asset details table
fprintf('BASKET ASSET DETAILS\n');
fprintf('-----------------------------------------------------------------------\n');

Assets = ["ENI"; "AXA"];
Initial_Price = [12.3; 22.1];
Volatility_Pct = [20.1; 18.3];
Dividend_Pct = [3.2; 2.9];
Weight_Pct = [50; 50];

detailTable = table(Assets, Initial_Price, Volatility_Pct, Dividend_Pct, Weight_Pct, ...
    'VariableNames', {'Asset', 'S0_EUR', 'Volatility_Pct', 'Dividend_Pct', 'Weight_Pct'});

disp(detailTable);
fprintf('\n');

end
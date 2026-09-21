function printExercise2Report(Notional, payoff_DO, ref_date, mat_date, df_mat, DO_Black, Correction, Corrected_Price, details_BP, details_Corr)
% PRINTEXERCISE2REPORT Prints a formatted valuation and risk report for Exercise 2.
%
% INPUTS:
%   Notional       : The Principal Amount of the contract (scalar).
%   payoff_DO      : The actual digital payoff amount in EUR (scalar).
%   ref_date       : The initial valuation date of the contract (datetime).
%   mat_date       : The maturity date of the option (datetime).
%   df_mat         : The exact interpolated discount factor at maturity B(t0, t).
%   DO_Black       : The price of the pure Black digital option (1 EUR payoff).
%   Correction     : The monetary value of the smile correction term (1 EUR payoff).
%   Corrected_Price: The final implied price after smile adjustment (1 EUR payoff).
%   details_BP     : Struct containing Black pricing details (T, F0, sigma).
%   details_Corr   : Struct containing correction details (Slope, Vega).
%
% OUTPUTS:
%   None (Prints formatted text directly to the Command Window).

fprintf('\n');
fprintf('============================================================\n');
fprintf('    EXERCISE 2: DIGITAL OPTION PRICING & SMILE RISK\n');
fprintf('============================================================\n');
fprintf('Notional Amount           : EUR %15.2f\n', Notional);
fprintf('Digital Payoff (5%%)       : EUR %15.2f\n', payoff_DO);
fprintf('Start Date                : %19s\n', datestr(ref_date, 'dd-mmm-yyyy'));
fprintf('Maturity Date             : %19s\n', datestr(mat_date, 'dd-mmm-yyyy'));
fprintf('------------------------------------------------------------\n');
fprintf('--- Market & Model Parameters ---\n');
fprintf('Discount Factor (1y)      : %19.6f\n', df_mat);
fprintf('ATM Forward (F0)          : %19.2f\n', details_BP.F0);
fprintf('ATM Volatility            : %17.2f %%\n', details_BP.sigma * 100);
fprintf('Volatility Slope (dSig/dK): %19.6f\n', details_Corr.Slope);
fprintf('Black-76 Vega             : %19.6f\n', details_Corr.Vega);
fprintf('------------------------------------------------------------\n');
fprintf('--- Prices per Unit (1 EUR Payoff) ---\n');
fprintf('Pure Black Price          : %15.6f EUR\n', DO_Black);
fprintf('Smile Correction Term     : %15.6f EUR\n', Correction);
fprintf('Corrected Implied Price   : %15.6f EUR\n', Corrected_Price);
fprintf('------------------------------------------------------------\n');
fprintf('--- Final Realized Prices (Actual Payoff) ---\n');
fprintf('Pure Black Value          : EUR %15.2f\n', DO_Black * payoff_DO);
fprintf('Smile Correction Impact   : EUR %15.2f\n', -Correction * payoff_DO);
fprintf('>>> FINAL CORRECTED VALUE : EUR %15.2f\n', Corrected_Price * payoff_DO);
fprintf('>>> FINAL DIFFERENCE VALUE: EUR %15.2f\n', -Correction * payoff_DO);
fprintf('============================================================\n\n');

end
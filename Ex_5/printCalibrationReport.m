function printCalibrationReport(sigma_hat, kappa_hat, eta_hat, fval)
% PRINTCALIBRATIONREPORT Prints a formatted report of the calibrated NTS
% (alpha=2/3) model parameters for Exercise 5.
%
% INPUTS:
%   sigma_hat : Calibrated volatility level.
%   kappa_hat : Calibrated vol-of-vol.
%   eta_hat   : Calibrated skewness parameter.
%   fval      : Objective function value at the optimum.

fprintf('\n');
fprintf('============================================================\n');
fprintf('    EXERCISE 5: NTS VOLATILITY SURFACE CALIBRATION\n');
fprintf('============================================================\n');
fprintf('Calibrated sigma (vol level)   : %15.4f\n', sigma_hat);
fprintf('Calibrated kappa (vol-of-vol)  : %15.4f\n', kappa_hat);
fprintf('Calibrated eta (skewness)      : %15.4f\n', eta_hat);
fprintf('Objective function value       : %15.4f\n', fval);
fprintf('============================================================\n\n');

end
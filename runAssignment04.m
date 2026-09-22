% runAssignment04
% AY2025-2026

clc; clear; close all
format long

projectRoot = fileparts(which('runAssignment04.m'));
addpath(genpath(projectRoot));

%% Bootstrap 
formatDate = 'dd/mm/yyyy';
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap.xls', formatDate);

[dates, discounts, zeroRates] = bootstrap(datesSet, ratesSet);

%% Exercise 1

% Parameters
Principal = 1e8; Protection = 0.95;
alpha = 1.1; weights = [1/2; 1/2]; spread = 0.013;

% Eni
S0_ENI = 12.3; sigma_ENI = 0.201; d_ENI = 0.032;

% AXA
S0_AXA = 22.1; sigma_AXA = 0.183; d_AXA = 0.029;

% Corr 
rho = 0.49;

ref_date = dates(1); convention1 = 'following';
mat_date = businessDateOffsetTarget(ref_date, 5, 0, 0, convention1);

num_payment_a_year = 4; convention2 = 'modifiedfollowing';
[pay_dates, details_dates] = computePaymentDates(ref_date, mat_date, ...
    num_payment_a_year, convention2);

[df_mat, coupon, details_coupon] = computeCouponMomentMatching(alpha, ref_date, ...
    mat_date, dates, discounts, weights, Protection, d_ENI, d_AXA, rho, ...
    sigma_ENI, sigma_AXA, Principal);

% Check for Coupon
rng(42, 'twister');
Nsim = 1e7;
T = yearfrac(ref_date, mat_date, 3);
[MC_Coupon, Call_MC, MC_Error] = computeCouponMC(Nsim, alpha, T, df_mat, weights, ...
    Protection, d_ENI, d_AXA, rho, sigma_ENI, sigma_AXA, Principal);

BPV_f = computeBPVFloater(pay_dates, dates, discounts, ref_date);

X_perc = 1 - df_mat + spread*BPV_f + (1-Protection)*df_mat - (coupon/Principal);
X_percMC = 1 - df_mat + spread*BPV_f + (1-Protection)*df_mat - (MC_Coupon/Principal);
% Report Ex1
printExercise1Report(Principal, ref_date, mat_date, Protection, alpha, spread, ...
    rho, df_mat, BPV_f, coupon, X_perc, details_dates, details_coupon, X_percMC, MC_Error);

%% Exercise 2

% Parameters
Notional = 1e7; payoff_DO = 0.05 * Notional;

ref_date = dates(1); convention1 = 'following';
mat_date = businessDateOffsetTarget(ref_date, 1, 0, 0, convention1);
df_mat = getDiscountFactorByZeroRatesLinearInterp(ref_date, mat_date, dates, discounts);

% Extract data from the dataset at disposal
mkt_data = load('eurostoxx_Poli.mat');

[D0_Black, details_BP] = computeBlackPrice(df_mat, mkt_data, ref_date, mat_date);

[Correction, details_Corr] = computeCorrectionTerm(mkt_data, df_mat, ref_date, mat_date);
Corrected_Price = D0_Black - Correction;

% Report Ex2
printExercise2Report(Notional, payoff_DO, ref_date, mat_date, df_mat, D0_Black, ...
    Correction, Corrected_Price, details_BP, details_Corr);

%% Plot Implied Volatility Smile
plotImpliedVolatilitySmile(mkt_data, details_Corr, df_mat, ref_date, mat_date);

%% Exercise 5

% Extract market parameters
S0 = mkt_data.cSelect.reference;
q = mkt_data.cSelect.dividends;
strikes = mkt_data.cSelect.strikes; 
vols_1y = mkt_data.cSelect.surface; 

dt = yearfrac(ref_date, mat_date, 3);
F0 = S0 * exp(-q*dt)/df_mat;
x = log(F0./strikes);

% Compute the Call Prices of the MKT
CallPricesMkt = computePriceMkt(S0, q, strikes, vols_1y, df_mat, ref_date, mat_date);

weights = ones(size(CallPricesMkt)); % Constant weights
alpha = 2/3;
p0 = [0.20, 1.0, 0.10]; % starting [sigma, kappa, eta] in the allowed set

obj_fun = @(p) minimizationFunction(p, alpha, dt, F0, df_mat, x, CallPricesMkt, weights);

% Run optimizer silently
options = optimset('Display', 'off', ...
                   'MaxFunEvals', 3000, ...
                   'MaxIter', 3000, ...
                   'TolFun', 1e-5, ...
                   'TolX', 1e-5);

[p_calibrated, fval, exitflag] = fminsearch(obj_fun, p0, options);

if exitflag == 1
    fprintf('Calibration successful!\n');
else
    fprintf('Warning: Calibration stopped early. Exitflag: %d\n', exitflag);
end

printCalibrationReport(p_calibrated(1), p_calibrated(2), p_calibrated(3), fval);

% Compute Implied Volatilities
CallPricesModel = computeCallPricesNMVM(p_calibrated, alpha, F0, df_mat, dt, x);
ModelImpliedVols = computeImpliedVol(CallPricesModel, strikes, F0, dt, df_mat);

%% Plot Implied Volatility Model VS Market
plotImpliedVolModelVSMkt(vols_1y, ModelImpliedVols, x);
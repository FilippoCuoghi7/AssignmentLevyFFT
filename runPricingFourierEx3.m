% runPricingFourier Ex3

clc; clear; close all
format long

projectRoot = fileparts(which('runPricingFourierEx3.m'));
addpath(genpath(projectRoot));

%% Bootstrap 
formatDate = 'dd/mm/yyyy';
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap.xls', formatDate);

[dates, discounts, zeroRates] = bootstrap(datesSet, ratesSet);

%% Exercise 3

% Parameters
p_plus = 1.5; p_minus = 0.9;
x = [-0.05223; 0; 0.15];
mu = log( (1 - 1/p_plus) * (1 + 1/p_minus) ); % Martingale Condition: phi(-i) = 1.

ref_date = dates(1); convention1 = 'following';
mat_date = businessDateOffsetTarget(ref_date, 1, 0, 0, convention1);
df_mat = getDiscountFactorByZeroRatesLinearInterp(ref_date, mat_date, dates, discounts);

% Extract data from the dataset at disposal
mkt_data = load('eurostoxx_Poli.mat');
F0 = computeFwd(mkt_data, df_mat, ref_date, mat_date);

% Characteristic function for this model (given)
phi = @(u) exp(1i*mu.*u) .* (1 ./ ((1 - u.*1i/p_plus) .* (1 + u.*1i/p_minus)));

% Generate the integrand handle, ready to be evaluated (for the 3 different x's)
integrand_handle = computeIntegrandLewis(x, phi);

% a) Quadrature
U_max = 100; N = 10000;

% Compute the integral and the Call price via Trapezoidal Quadrature
int_val_Trapz = computeIntegralTrapz(integrand_handle, U_max, N);
Call_Trapz = computeCallPrice(F0, df_mat, int_val_Trapz, x);

% Compute the integral and the Call price via Rectangular Quadrature
int_val_Rect = computeIntegralRect(integrand_handle, U_max, N);
Call_Rect = computeCallPrice(F0, df_mat, int_val_Rect, x);

% Compute the integral and the Call price via Quadrature
int_val_Quad = computeIntegralQuadGK(phi, x);
Call_Quad = computeCallPrice(F0, df_mat, int_val_Quad, x);


% b) Residuals
int_val_Residuals = computeIntegralResiduals(p_plus, p_minus, mu, x);
Call_Residuals = computeCallPrice(F0, df_mat, int_val_Residuals, x);

% c) MC Simulations 
rng(42, 'twister');
Nsim = 1e7;
Call_MC = computeCallPriceMC(Nsim, p_plus, p_minus, mu, F0, df_mat, x);

% d) FFT (we actually perform the Inverse Fourier Transform)
integrand_FFT = @(u) (1/(2*pi)) .* phi(-u - 0.5i) .* (1 ./ (u.^2 + 0.25)); % Lewis integrand.

% d.1) FFT Parameters
x1 = -125;
M = 15;

% FFT Call Price
[fhat, ~, z_grid] = computeIntegralFFT(integrand_FFT, M, x1, [], []);
int_val_FFT = interp1(z_grid, fhat, x, 'spline');
Call_FFT = computeCallPrice(F0, df_mat, int_val_FFT, x);

% Indirect MC Call Price
Call_Price_IndirectMC = computeCallMCFFTCDF(Nsim, phi, F0, df_mat, M, x1, [], [], x);

% CDF reconstruction plots (Report Fig. 2 & 3)
plotCdfReconstruction(phi, F0, df_mat, M, x1, [], [], Nsim, 'Double Exponential', 42);

% d.2) FFT Parameters
M = 15;
dz = 0.0025;

% FFT Call Price
[fhat2, ~, z_grid2] = computeIntegralFFT(integrand_FFT, M, [], [], dz);
int_val_FFT2 = interp1(z_grid2, fhat2, x, 'spline');
Call_FFT2 = computeCallPrice(F0, df_mat, int_val_FFT2, x);

% Indirect MC Call Price
Call_Price_IndirectMC2 = computeCallMCFFTCDF(Nsim, phi, F0, df_mat, M, [], [], dz, x);

%% Comparisons

% FFT Prices
compareFFTSensitivity(x, Call_FFT, Call_FFT2, 'FFT1 (x1 fixed) VS FFT2 (dz fixed)');

% MC Prices
compareMCVarieties(x, Call_MC, Call_Price_IndirectMC, 'MC Direct VS MC Indirect (x1 fixed)');
compareMCVarieties(x, Call_MC, Call_Price_IndirectMC2, 'MC Direct VS MC Indirect (dz fixed)');

% Quadrature Prices
compareQuadratureMethods(x, Call_Rect, Call_Trapz, Call_Quad, 'Quadrature Techniques');

% Total Comparison across different methodologies
compareComprehensiveMethods(x, Call_Residuals, Call_Quad, Call_MC, Call_FFT, 'Comprehensive Methods');
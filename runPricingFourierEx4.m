% runPricingFourier Ex4

clc; clear; close all
format long

projectRoot = fileparts(which('runPricingFourierEx4.m'));
addpath(genpath(projectRoot));

%% Bootstrap 
formatDate = 'dd/mm/yyyy';
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap.xls', formatDate);

[dates, discounts, zeroRates] = bootstrap(datesSet, ratesSet); 

%% Exercise 4 NIG

% Parameters

ref_date = dates(1); convention1 = 'following';
mat_date = businessDateOffsetTarget(ref_date, 1, 0, 0, convention1);
df_mat = getDiscountFactorByZeroRatesLinearInterp(ref_date, mat_date, dates, discounts);
alpha = 1/2; % NIG
dt = yearfrac(ref_date, mat_date, 3); % act/365 
eta = 3;
kappa = 1; sigma = 0.20; 
x_1 = -0.25; % Start at -25% 
dx = 0.01;   % Step size of 1%
x = x_1:dx:-x_1; % From -0.25 to +0.25

% Safety Check: eta > - w_bar
w_bar = (1-alpha) / (kappa*sigma^2);
if (eta <= -w_bar)
    error('Pricing Error: eta (%.4f) violates the log-Laplace domain bounds. It must be strictly greater than -w_bar (%.4f)', eta, -w_bar);
end

% Extract data from the dataset at disposal
mkt_data = load('eurostoxx_Poli.mat');

% Extract market parameters
S0 = mkt_data.cSelect.reference;
q = mkt_data.cSelect.dividends; 

F0 = S0 * exp(-q*dt)/df_mat;

% Char Function of NMVM
phi = buildCharFunG(sigma, kappa, eta, dt, alpha);

% a) FFT (we actually perform the Inverse Fourier Transform)
integrand_FFT_NIG = @(u) (1/(2*pi)) .* phi(-u - 0.5i) .* (1 ./ (u.^2 + 0.25)); % Lewis integrand.

% a.1) FFT Parameters
x1 = -125;
M = 15;

% FFT Call Price
[fhat, ~, z_grid] = computeIntegralFFT(integrand_FFT_NIG, M, x1, [], []);
int_val_FFT_NIG = interp1(z_grid, fhat, x, 'spline');
CallPrices_FFT_NIG = computeCallPrice(F0, df_mat, int_val_FFT_NIG, x);

% a.2) FFT Parameters
M = 15;
dz = 0.0025;

% FFT Call Price
[fhat2, ~, z_grid2] = computeIntegralFFT(integrand_FFT_NIG, M, [], [], dz); 
int_val_FFT2_NIG = interp1(z_grid2, fhat2, x, 'spline');
CallPrices_FFT2_NIG = computeCallPrice(F0, df_mat, int_val_FFT2_NIG, x);

% b) Quadrature
int_val_Quad_NIG = computeIntegralQuadGK(phi, x);
CallPrices_Quad_NIG = computeCallPrice(F0, df_mat, int_val_Quad_NIG, x);

% c) MC
rng(42, 'twister');
Nsim = 1e7;
CallPricesMC_NIG = computeCallPricesMC(Nsim, sigma, eta, kappa, dt, F0, df_mat, x, alpha);

% Verify the matching of the moments of the simulated and the analytical IG
[EmpMoments_NIG, TheoMoments_NIG] = verifyIGMoments(Nsim, kappa, dt);

% d) Facultative
alpha2 = 1/3;

% Safety Check: eta > - w_bar
w_bar2 = (1-alpha2) / (kappa*sigma^2);
if (eta <= -w_bar2)
    error('Pricing Error: eta (%.4f) violates the log-Laplace domain bounds. It must be strictly greater than -w_bar (%.4f)', eta, -w_bar2);
end

phi2 = buildCharFunG(sigma, kappa, eta, dt, alpha2);
% FFT
integrand_FFT = @(u) (1/(2*pi)) .* phi2(-u - 0.5i) .* (1 ./ (u.^2 + 0.25)); % Lewis integrand.

% 1) FFT Parameters
x1 = -125;
M = 15;

% FFT Call Price
[fhat, ~, z_grid] = computeIntegralFFT(integrand_FFT, M, x1, [], []); % we interpolate on the z's
int_val_FFT = interp1(z_grid, fhat, x, 'spline');
CallPrices_FFT = computeCallPrice(F0, df_mat, int_val_FFT, x);

% 2) FFT Parameters
M = 15;
dz = 0.0025;

% FFT Call Price
[fhat2, ~, z_grid2] = computeIntegralFFT(integrand_FFT, M, [], [], dz); % we interpolate on the z's
int_val_FFT2 = interp1(z_grid2, fhat2, x, 'spline');
CallPrices_FFT2 = computeCallPrice(F0, df_mat, int_val_FFT2, x);

% Quadrature
int_val_Quad = computeIntegralQuadGK(phi, x);
CallPrices_Quad = computeCallPrice(F0, df_mat, int_val_Quad, x);

%% Price Comparison

% NIG(alpha = 1/2) - Comparing FFT1 and FFT2
compareFFTSensitivity(x, CallPrices_FFT_NIG, CallPrices_FFT2_NIG, 'NIG (alpha=1/2) - FFT1 VS FFT2');
% Case 1: NIG (alpha = 1/2) - Comparing FFT1, Quad, and MC
comparePricingMethods(x, CallPrices_FFT_NIG, CallPrices_Quad_NIG, CallPricesMC_NIG, 'NIG (alpha=1/2) Case 1');
% Case 2: NIG (alpha = 1/2) - Comparing FFT2, Quad, and MC
comparePricingMethods(x, CallPrices_FFT2_NIG, CallPrices_Quad_NIG, CallPricesMC_NIG, 'NIG (alpha=1/2) Case 2');

% facultative (alpha = 1/3) - Comparing FFT1 and FFT2
compareFFTSensitivity(x, CallPrices_FFT, CallPrices_FFT2, 'Facultative (alpha=1/3) - FFT1 VS FFT2');
% Case 1: Facultative (alpha = 1/3) - Comparing FFT1 and Quad only
comparePricingMethods(x, CallPrices_FFT, CallPrices_Quad, [], 'Facultative (alpha=1/3) Case 1');
% Case 2: Facultative (alpha = 1/3) - Comparing FFT2 and Quad only
comparePricingMethods(x, CallPrices_FFT2, CallPrices_Quad, [], 'Facultative (alpha=1/3) Case 2');



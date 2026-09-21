function Lewis_integral = computeIntegralRect(integrand, U_max, N)
% COMPUTE_INTEGRAL_RECT Computes the numerical integral of a given
% function over a symmetric grid [-U_max, U_max] using the Rectangular rule
% (Left Riemann sum). Handles both scalar and vectorized (matrix) integrands.
%
% INPUTS:
%   integrand : A function handle @(u) that evaluates the integrand.
%               Can return a 1xN vector or an MxN matrix.
%   U_max     : The scalar upper (and absolute lower) truncation limit.
%   N         : The scalar number of discretization points.
%
% OUTPUTS:
%   Lewis_integral : The evaluated integral(s). Outputs an Mx1 column
%                    vector if the integrand returns an MxN matrix.

% Build the discrete integration grid (from -U_max to +U_max)
u = linspace(-U_max, U_max, N); % (1 x N)

% Calculate the step size (du - uniform width of the base of every rectangle)
du = u(2) - u(1);

% Evaluate your integrands over the entire grid
y = integrand(u); % (3 x N)

% Perform numerical integration using the Left Rectangular rule
% We slice 'y' to take all rows (:) and all columns except the last (1:end-1).
Lewis_integral = sum(y(:, 1:end-1), 2) * du;
% The '2' explicitly forces MATLAB to sum horizontally across the grid points.

end
function Lewis_integral = computeIntegralTrapz(integrand, U_max, N)
% COMPUTE_INTEGRAL_TRAPZ Computes the numerical integral of a given
% function over a symmetric grid [-U_max, U_max] using the Trapezoidal rule.
% Handles both scalar and vectorized (matrix) integrands.
%
% INPUTS:
%   integrand : A vector of functions handle @(u) that evaluate the integrands over a grid.
%   U_max     : The scalar upper (and absolute lower) truncation limit for the grid.
%   N         : The scalar number of discretization points for the grid.
%
% OUTPUTS:
%   Lewis_integral : The values of the evaluated integrals.

% Build the discrete integration grid (from -U_max to +U_max)
u = linspace(-U_max, U_max, N); % (1 x N)

% Evaluate your integrands over the entire grid
y = integrand(u); % (3 x N)

% Perform numerical integration using the Trapezoidal rule
Lewis_integral = trapz(u, y, 2);
% The '2' explicitly forces MATLAB to integrate horizontally across 
% the N grid points (dimension 2), calculating the area for each row.

end
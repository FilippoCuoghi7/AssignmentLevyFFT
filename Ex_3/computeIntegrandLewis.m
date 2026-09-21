function Lewis_integrand = computeIntegrandLewis(x, fun_char)
% COMPUTE_INTEGRAND_LEWIS Generates a function handle for the Lewis (2001)
% integrand
%
% INPUTS:
%   x       : The (scalar or vector) log-moneyness of the option, defined as ln(F0 / K).
%   fun_char: The characteristic function of the logReturns of the fwd price.
%
% OUTPUTS:
%   Lewis_integrand : A function handle @(z) that takes a numerical grid 'z'
%                     and evaluates the complex integrand needed for the Lewis
%                     pricing formula.

% Ensure x is a column vector
x_col = x(:);

% Returns the function handle for the integrand (Obs: 1i is used instead of i)
Lewis_integrand = @(z) (exp(-1i*x_col.*z) ./ (2*pi)) .* fun_char(-z - 0.5i) .* (1 ./ (z.^2 + 0.25));

end
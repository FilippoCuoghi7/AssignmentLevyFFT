function Lewis_integral = computeIntegralQuadGK(fun_char, x)
% COMPUTE_INTEGRAL_QUADGK Computes the exact Lewis integral using quadgk
% over the infinite domain [-Inf, Inf].
%
% INPUTS:
%   fun_char : A function handle for the characteristic function @(u).
%   x        : The log-moneyness (scalar or vector).
%
% OUTPUTS:
%   Lewis_integral : The evaluated integral(s) as an array matching the size of x.

% Pre-allocate the output array to exactly match the size of x
Lewis_integral = zeros(size(x));

% Loop through each strike cleanly
for j = 1:length(x)
    current_x = x(j);

    scalar_integrand = computeIntegrandLewis(current_x, fun_char);

    % quadgk handle the infinite bounds seamlessly
    Lewis_integral(j) = quadgk(scalar_integrand, -Inf, Inf);
end

end
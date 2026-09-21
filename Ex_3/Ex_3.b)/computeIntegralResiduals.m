function integral = computeIntegralResiduals(p_plus, p_minus, mu, x)
% COMPUTE_INTEGRAL_RESIDUALS Calculates the Lewis (2001) integral
% using the Residue Theorem. Fully vectorized for performance.
%
% INPUTS:
%   p_plus   : The right-tail parameter (scalar).
%   p_minus  : The left-tail parameter (scalar).
%   mu       : The risk-neutral drift parameter (scalar).
%   x        : The log-moneyness of the option ln(F0/K) (scalar/vector).
%
% OUTPUTS:
%   integral : The Lewis integral using the Residuals of the integrand.

% Initialize the output array to match the size of x
integral = zeros(size(x));

% Create logical masks for our two conditions
idx_UHP = (x + mu) < 0;   % Logical array of 1s where UHP is true, 0s where false
idx_LHP = ~idx_UHP;       % Logical array of the exact opposites (LHP)

% Pre-calculate the scalar coefficients (done once, outside any logic)
coeff_UHP = p_minus / ((p_plus - 1) * (p_plus + p_minus));
coeff_LHP = p_plus / ((p_minus + 1) * (p_plus + p_minus));

% Process all UHP elements simultaneously (if there are any)
if any(idx_UHP)
    x_UHP = x(idx_UHP); % Extract only the x values that meet the UHP condition

    Res_1_UHP = exp(x_UHP ./ 2); % 2*pi*Res(0.5i).
    Res_2_UHP = -coeff_UHP .* exp(p_plus .* (x_UHP + mu)) .* exp(-x_UHP ./ 2); % 2*pi*Res((p_plus-0.5)i).

    % Drop the computed values exactly back into their original slots
    integral(idx_UHP) = Res_1_UHP + Res_2_UHP;
end

% Process all LHP elements simultaneously (if there are any)
if any(idx_LHP)
    x_LHP = x(idx_LHP); % Extract only the x values that meet the LHP condition

    Res_1_LHP = exp(-x_LHP ./ 2); % 2*pi*Res(-0.5i).
    Res_2_LHP = -coeff_LHP .* exp(-p_minus .* (x_LHP + mu)) .* exp(-x_LHP ./ 2); % 2*pi*Res(-i(p_minus+0.5).

    % Drop the computed values exactly back into their original slots
    integral(idx_LHP) = Res_1_LHP + Res_2_LHP;
end

end
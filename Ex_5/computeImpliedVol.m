function ModelImpliedVols = computeImpliedVol(CallPricesModel, strikes, F0, dt, df_mat)
% COMPUTE_IMPLIED_VOL_FSOLVE Backs out implied volatilities from Call option
% prices using a vectorized fsolve over the Black-76 formula.
%
% Solved in y = log(v) so v = exp(y) is positive by construction (no
% explicit bounds needed).
%
% Inputs:
%   CallPricesModel : (Vector) Target model Call prices
%   strikes         : (Vector) Strike prices
%   F0              : ATM Forward price
%   dt              : Time to maturity
%   df_mat          : Discount factor
%
% Output:
%   ModelImpliedVols : (Vector) Implied volatilities matching the strikes

% Ensure inputs are column vectors to prevent matrix expansion bugs
K = strikes(:);
P = CallPricesModel(:);

% Vectorized Black-76 formula
d1 = @(v) (log(F0./K) + 0.5 * v.^2 * dt) ./ (v * sqrt(dt));
d2 = @(v) d1(v) - v * sqrt(dt);
black76_call = @(v) df_mat * (F0 * normcdf(d1(v)) ...
    - K .* normcdf(d2(v)));

% Objective in y = log(v): v = exp(y) > 0 always, whatever fsolve does
obj_y = @(y) black76_call(exp(y)) - P;

% Initial guess
y0 = log(0.20) * ones(size(K));

% Solve, then map back y -> v
options = optimoptions('fsolve', 'Display', 'off');
y_sol = fsolve(obj_y, y0, options);
ModelImpliedVols = exp(y_sol);

end
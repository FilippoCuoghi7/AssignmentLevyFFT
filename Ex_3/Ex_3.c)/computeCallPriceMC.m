function Call_PriceMC = computeCallPriceMC(Nsim, p_plus, p_minus, mu, F0, df_mat, x)
% CALL_PRICEMC Computes the Monte Carlo price of a European call option.
% Vectorized to handle multiple strikes (x) in a single simulation run.
%
%   Inputs:
%       Nsim    : number of Monte Carlo simulations
%       p_plus  : positive rate of the upward exponential component
%       p_minus : positive rate of the downward exponential component
%       mu      : drift fixed by the martingale condition
%       F0      : ATM forward
%       df_mat  : discount factor
%       x       : log-moneyness, x = log(F0/K) (Scalar or Vector)
%
%   Output:
%       Call_PriceMC : Monte Carlo estimate of the call price(s)

% Ensure 'x' is a row vector (1 x M)
x_row = x(:)';

% Simulate logReturns (done ONCE, 'ft' is a column vector (Nsim x 1))
ft = mu + exprnd(1/p_plus, Nsim, 1) - exprnd(1/p_minus, Nsim, 1);

% Calculate Payoffs (via implicit expansion --> exp(ft) is (Nsim x 1), exp(-x_row) is (1 x M).
% Then, subtracting them creates an (Nsim x M) matrix of all payoffs)
payoffs = max(exp(ft) - exp(-x_row), 0);

% Compute the mean down the columns (dimension 1) to get the expected
% payoff for each strike, then discount to present value.
Call_PriceMC = df_mat * F0 * mean(payoffs, 1);

end
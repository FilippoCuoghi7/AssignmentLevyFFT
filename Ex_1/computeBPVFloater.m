function BPV = computeBPVFloater(payment_dates, dates, discounts, start_date)
% COMPUTE_BPV_FLOATER Calculates the Basis Point Value (BPV) of a floating leg.
%
% INPUTS:
%   payment_dates: Column vector of scheduled payment dates (t_1 to t_N) (datetime).
%   dates:         Array of dates representing the pillars of the yield curve.
%   discounts:     Array of discount factors corresponding to the 'dates' pillars.
%   start_date:    The initial starting date of the swap (t_0) (scalar datetime).
%
% OUTPUTS:
%   BPV:           The scalar Basis Point Value for the floating leg.

% Extract discount factors for all payment dates
dfs = getDiscountFactorByZeroRatesLinearInterp(start_date, payment_dates, dates, discounts);

% Create the full schedule including the start date
new_dates = [start_date; payment_dates(:)];

% Calculate year fractions (Act/360)
yearfracs = yearfrac(new_dates(1:end-1), new_dates(2:end), 2);

% Compute BPV
BPV = sum(dfs(:) .* yearfracs(:));

end
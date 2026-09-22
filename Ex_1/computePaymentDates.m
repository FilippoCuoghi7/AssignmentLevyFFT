function [payment_dates, details] = computePaymentDates(start_date, end_date, ...
    num_payment_a_year, convention)
% COMPUTE_PAYMENT_DATES Computes a vectorized schedule of adjusted payment
% dates for a financial contract between a start and end date.
%
% INPUTS:
%   start_date:         The initial starting date of the contract.
%   end_date:           The final maturity date of the contract.
%   num_payment_a_year: The number of payments per year.
%   convention:         A string or character vector specifying the business day convention
%                       to apply ('following' or 'modifiedfollowing').
%
% OUTPUTS:
%   payment_dates:      A column vector of datetime objects representing all scheduled
%                       payment dates, adjusted for business days, concluding with the
%                       adjusted final maturity date.
%   details:            Struct containing variables for reporting.

delta_t = 12/num_payment_a_year; % in months

% Find the total number of months payment_dates between start_date and end_date
total_months_diff = split(between(start_date, end_date, 'Months'), 'Months');
num_periods = floor(total_months_diff / delta_t);

% Create a vector of months to add
%multipliers = (1:num_periods)';
%months_to_add_vector = multipliers * delta_t;

% Call the BUSINESSDATEOFFSETTARGET function ONCE with the vector of months to add
% schedule = businessDateOffsetTarget(start_date, 0, months_to_add_vector,
% 0, convention); <-- problem inside businessDateOffsetTarget.

schedule = NaT(num_periods, 1);

% Loop through each period and call the helper function ONE AT A TIME
for i = 1:num_periods
    months_to_add = i * delta_t;
    schedule(i) = businessDateOffsetTarget(start_date, 0, months_to_add, 0, convention);
end

% Safety Check for end_date
if ~isempty(schedule) && schedule(end) == end_date
    payment_dates = schedule;
else
    payment_dates = [schedule; end_date];
end

% Details for the report
details = struct();

details.num_payment_in_a_year = num_payment_a_year;
details.num_periods = num_periods;

end
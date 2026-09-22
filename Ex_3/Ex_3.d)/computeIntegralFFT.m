function [fhat, x, z] = computeIntegralFFT(f, M, x1, z1, dz)
% computeIntegralFFT Compute discrete Fourier transform via FFT following
% the convention dx*dz = 2*pi/N.
%
%   Inputs:
%       f  : function handle
%            Function f(x) to be sampled on the x-grid.
%       M  : integer
%            Power such that N = 2^M is the number of grid points.
%       x1 : scalar
%            Left endpoint of the x-grid.
%       z1 : scalar
%            Left endpoint of the z-grid (optional).
%       dz : dimension of the step in the z-grid (optional).
%
%   Outputs:
%       fhat : vector
%              Approximation of the Fourier transform at points z_k.
%       x    : vector
%              x-grid (spatial grid).
%       z    : vector
%              z-grid (Fourier grid).
%
%   Notes:
%       - Uses the convention:
%         fhat(z_k) = dx * exp(-1i*x1*z_k) * FFT{ f_j * exp(-1i*z1*dx*(j-1)) }
%       - Grids:
%           x_j = x1 + (j-1)*dx
%           z_k = z1 + (k-1)*dz
%       - Constraint: dx * dz = 2*pi / N

N  = 2^M;

if isempty(dz)
    % User omitted dz (passed []). Calculate dx assuming a symmetric x-grid [-x1, x1],
    % then compute dz from the Nyquist relation: : dz*dx = 2pi/N.
    dx = (-x1 - x1) / N;  % x1 <0
    dz = (2 * pi) / (N * dx);
elseif isempty(x1)
    % User provided dz, but omitted x1 (passed []).
    % Calculate dx strictly from the Nyquist relation, then compute x1
    % assuming a symmetric grid.
    dx = (2 * pi) / (N * dz);
    x1 = -N*dx/2;
else
    % User provided both dz and x1 --> error: we can't assure the Nyquist
    % relation and at the same time the symmetry of x_grid.
    error("x1 and dz can't be both given")
end

% If the user passed [] for z1, calculate it assuming a symmetric grid (center on the ATM). 
if isempty(z1)
    z1 = -(N * dz) / 2;
end

% Grids
x = x1 + (0:N-1) * dx;
z = z1 + (0:N-1) * dz;

phase = exp(-1i * z1 * dx * (0:N-1)); % phase correction
fj = f(x).*phase; 
prefactor = dx .* exp(-1i * x1 .* z);

% FFT --> fft command already handles the missing term:
% exp(-1i*(j-1)*(k-1)*2*pi/N), looping through every value of k.
fhat = prefactor .* fft(fj);

end
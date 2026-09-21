function d = priceDigitalFFT(f, x, B, M, x1, z1, dz)
% PRICE_DIGITAL_FFT Compute digital option prices by Fast Fourier Transform method.
%
%   Inputs:
%       f  : characteristic function handle phi(z)
%       x  : log-moneyness x = log(F0/K)
%       B  : discount factor B(t0,t)
%       M  : integer, N = 2^M FFT grid points
%       x1 : (optional) first point of integration grid
%       z1 : (optional) first point of output grid
%       dz : (optional) dimension of the step in the z-grid
%
%   Output:
%       d  : price of the digital option, retrieved using FFT method.
%
% In this implementation, the numerical Fourier routine returns a quantity
% such that
%    D(x)/B = exp(x/2) * I(x)


g = @(xi) f(-xi - 1i/2) ./ (2*pi .* (1/2 - 1i .* xi));

if isempty(x1) && isempty(z1) && isempty(dz)
    error('priceDigitalFFT requires at least one of the 3 parameters.');
end

[Ifft, ~, z] = computeIntegralFFT(g, M, x1, z1, dz);
I = interp1(z, Ifft, x, 'spline');
d = real(B .* (exp(x./2) .* I));
end
function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN   Perform the actual design.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:38:26 $

% Validate specifications
[N,F,A,P,nfpts] = validatespecs(hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

% Interpolate magnitudes and phases on regular grid
nfft = min(max(2^nextpow2(N+1),max(2^nextpow2(nfpts),1024)),2^16); 
[ff,aa,pp] = interp_on_regular_grid(F,A,P,nfft,isreal);

% Build the Fourier Transform 
H = aa.*exp(j*pp);

% Inverse Fourier transform
if isreal,
    % Force Hermitian property of Fourier Transform
    H = [H conj(H(nfft:-1:2))];
    b = ifft(H,'symmetric');  
else
    b = ifft(fftshift(H),'nonsymmetric');
end

% Truncate filter
b = b(1:N+1);

% Apply Window
b = applywindow(this,b,N);

varargout = {{b}};

%--------------------------------------------------------------------------
function [ff,aa,pp] = interp_on_regular_grid(F,A,P,nfft,isreal)
% Interpolate magnitudes and phases on regular grid

if isreal,
    % Use nfft+1 points for the positive frequencies (including nyquist): 
    % [dc 1 2 ... nyquist]
    ff = linspace(F(1),F(end),nfft+1);
else
    ff = linspace(F(1),F(end),nfft);
end
aa = interp1(F,A,ff);
pp = interp1(F,P,ff);

function [y,z,tapidx] = firinterpfilter(q,L,p,x,z,tapidx,nx,nchans,ny)
%FIRINTERPFILTER   Filtering method for fir interpolator.

%   Author(s): R. Losada
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:37 $

% Quantize input
x = quantizeinput(q,x);

if isreal(x) && isreal(z),
    y = zeros(ny,nchans,'single');
    sfirinterpfilter(p,L,x,y,z,tapidx);
else
    % Filter real part of input with real initial conditions
    yr = zeros(ny,nchans,'single');
    % Copy tap index
    lcltapidx = tapidx+0; % Force new memory allocation
    zr = real(z);
    sfirinterpfilter(p,L,real(x),yr,zr,lcltapidx);
    
    
    % Now filter imag part of input with imaginary initial conditions    
    yi = zeros(ny,nchans,'single');
    zi = imag(z);
    sfirinterpfilter(p,L,imag(x),yi,zi,tapidx);
    y = complex(yr,yi);
    z = complex(zr,zi);
end

% [EOF]

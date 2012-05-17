function [y,z,tapidx] = firsrcfilter(q,L,M,p,x,z,tapidx,im,inOffset,Mx,Nx,My)
%FIRINTERPFILTER   Filtering method for fir interpolator.

%   Author(s): R. Losada
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:42 $

% Quantize input
x = quantizeinput(q,x);

if isreal(x) && isreal(z),
    y = zeros(My,Nx,'single');
    sfirsrcfilter(p,L,M,x,y,z,tapidx,im,inOffset);
else
    % Filter real part of input with real initial conditions
    yr = zeros(My,Nx,'single');
    % Copy tap index
    tapidxc = tapidx+0; % Force new memory allocation
    zr = real(z);
    sfirsrcfilter(p,L,M,real(x),yr,zr,tapidx,im,inOffset);
    
    % Now filter imag part of input with imaginary initial conditions    
    yi = zeros(My,Nx,'single');    
    zi = imag(z);
    sfirsrcfilter(p,L,M,imag(x),yi,zi,tapidxc,im,inOffset);
    y = complex(yr,yi);
    z = complex(zr,zi);
end

% [EOF]

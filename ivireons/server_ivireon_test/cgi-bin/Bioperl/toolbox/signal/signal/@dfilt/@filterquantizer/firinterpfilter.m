function [y,z,tapidx] = firinterpfilter(q,L,p,x,z,tapidx,nx,nchans,ny)
%FIRINTERPFILTER   Filtering method for fir interpolator.

%   Author(s): R. Losada
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/05/23 19:13:16 $

% Quantize input
x = quantizeinput(q,x);
if isreal(p)
    if isreal(x) && isreal(z),
        y = zeros(ny,nchans);
        firinterpfilter(p,L,x,y,z,tapidx);
    else
         % Complex output
        [y,z,tapidx] = getcmplxoutput(p,L,x,z,tapidx,nx,nchans,ny);
    end
else
    preal = real(p);
    pimag = imag(p);
    
    lcltapidx = tapidx+0;       % force new memory allocation
    lclz = z+0;                 % force new memory allocation
    
    % Filter input with real part of coefficients (output1)
    [y1,zf1,lcltapidx] = getcmplxoutput(preal,L,x,lclz,lcltapidx,nx,nchans,ny);
       
    % Filter input with  imaginary part of coefficients (output2)
    [y2,zf2,tapidx] = getcmplxoutput(pimag,L,x,z,tapidx,nx,nchans,ny);
    
    % Combine both outputs. Output2 should be multiplied by i. Cannot use
    % COMPLEX function since both outputs could be complex numbers by themselves    
    y = y1+i*y2;
    z = zf1+i*zf2;   
    
end



%--------------------------------------------------------------------------
function  [y,z,tapidx] = getcmplxoutput(p,L,x,z,tapidx,nx,nchans,ny)
% GETCMPLXOUTPUT Get complex output

% Filter real part of input with real initial conditions
yr = zeros(ny,nchans);
% Copy tap index
lcltapidx = tapidx+0; % Force new memory allocation
zr = real(z);
firinterpfilter(p,L,real(x),yr,zr,lcltapidx);

% Now filter imag part of input with imaginary initial conditions
yi = zeros(ny,nchans);
zi = imag(z);
firinterpfilter(p,L,imag(x),yi,zi,tapidx);
y = complex(yr,yi);
z = complex(zr,zi);

% [EOF]

function [y,z,tapidx] = firsrcfilter(q,L,M,p,x,z,tapidx,im,inOffset,Mx,Nx,My)
%FIRINTERPFILTER   Filtering method for fir interpolator.

%   Author(s): R. Losada
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/05/23 19:13:17 $

% Quantize input
x = quantizeinput(q,x);

if isreal(p)
    if isreal(x) && isreal(z),
        y = zeros(My,Nx);
        firsrcfilter(p,L,M,x,y,z,tapidx,im,inOffset);
    else
        y = zeros(My,Nx);
        [y,z,tapidx] = getcmplxoutput(p,L,M,x,y,z,tapidx,im,inOffset,Nx,My);
    end
else
    preal = real(p);
    pimag = imag(p);
    
    lcltapidx = tapidx+0;       % force new memory allocation
    lclz = z+0;                 % force new memory allocation
    
    y1 = zeros(My,Nx);    
    % Filter input with real part of coefficients (output1)
    [y1,z1,lcltapidx] = getcmplxoutput(preal,L,M,x,y1,lclz,lcltapidx,im,inOffset,Nx,My);
    
    y2 = zeros(My,Nx);    
    % Filter input with imaginary part of coefficients (output1)
    [y2,z2,tapidx]    = getcmplxoutput(pimag,L,M,x,y2,z,tapidx,im,inOffset,Nx,My);
    
    % Combine both outputs. Output2 should be multiplied by i. Cannot use
    % COMPLEX function since both outputs may be complex numbers by themselves    
    y = y1+i*y2;
    z = z1+i*z2;      
    
end



% ------------------------------------------------------------------------
function  [y,z,tapidx] = getcmplxoutput(p,L,M,x,y,z,tapidx,im,inOffset,Nx,My)
% GETCMPLXOUTPUT Get complex output


% Filter real part of input with real initial conditions
yr = zeros(My,Nx);
% Copy tap index
tapidxc = tapidx+0; % Force new memory allocation
zr = real(z);
firsrcfilter(p,L,M,real(x),yr,zr,tapidx,im,inOffset);

% Now filter imag part of input with imaginary initial conditions
yi = zeros(My,Nx);
zi = imag(z);
firsrcfilter(p,L,M,imag(x),yi,zi,tapidxc,im,inOffset);
y = complex(yr,yi);
z = complex(zr,zi);
    
% [EOF]

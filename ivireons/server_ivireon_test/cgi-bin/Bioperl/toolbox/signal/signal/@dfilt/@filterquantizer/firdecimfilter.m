function [y, zf, acc, phaseidx, tapidx] = firdecimfilter(q,M,p,x,zi,acc,phaseidx,tapidx,nx,nchans,ny)
%FIRDECIMFILTER   

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/05/23 19:13:15 $

% Quantize input
x = quantizeinput(q,x);



if isreal(p)   
    if isreal(x) && isreal(zi) && isreal(acc),
        % Real output
        % Allocate memory for output
        y = zeros(ny,nchans);
        % Call C-mex
        firdecimfilter(p,M,x,zi,acc,phaseidx,tapidx,y);
        zf = zi;
    else   
        % Complex output
        [y,zf,acc,phaseidx,tapidx] = getcmplxoutput(p,M,x,zi,acc,phaseidx,tapidx,nx,nchans,ny);       
    end
else
    % Separate real and imaginary parts of the coefficients
    preal = real(p);
    pimag = imag(p);      
    
    lclphaseidx = phaseidx+0;   % force new memory allocation
    lcltapidx   = tapidx+0;     % force new memory allocation
    lclzi = zi+0;               % force new memory allocation
    
    % Filter input with real part of coefficients (output1)
    [y1,zf1,acc1,lclphaseidx,lcltapidx] = getcmplxoutput(preal,M,x,zi,acc,lclphaseidx,lcltapidx,nx,nchans,ny);  
   
    % Filter input with  imaginary part of coefficients (output2)
    [y2,zf2,acc2,phaseidx,tapidx] = getcmplxoutput(pimag,M,x,lclzi,acc,phaseidx,tapidx,nx,nchans,ny);    
    
    % Combine both outputs. Output2 should be multiplied by i. Cannot use
    % COMPLEX function since both outputs could be complex numbers by themselves
    
    y    = y1+i*y2;
    zf   = zf1+i*zf2;
    acc  = acc1+i*acc2;
    
end
       
    
%--------------------------------------------------------------------------
function [y,zf,acc,phaseidx,tapidx] = getcmplxoutput(p,M,x,zi,acc,phaseidx,tapidx,nx,nchans,ny)
% GETCMPLXOUTPUT Get complex output

lclphaseidx = phaseidx+0; % Force new memory allocation
lcltapidx = tapidx+0; % Force new memory allocation
% Real part
yr = zeros(ny,nchans);
xr = real(x);
zir = real(zi);
accr = real(acc);
firdecimfilter(p,M,xr,zir,accr,lclphaseidx,lcltapidx,yr);

% Imaginary part
yi = zeros(ny,nchans);
xi = imag(x);
zii = imag(zi);
acci = imag(acc);
firdecimfilter(p,M,xi,zii,acci,phaseidx,tapidx,yi);

y = complex(yr,yi);
zf = complex(zir,zii);
acc = complex(accr,acci);


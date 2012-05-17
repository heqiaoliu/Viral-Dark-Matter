function [y, zf, acc, phaseidx] = firtdecimfilter(q,M,p,x,zi,acc,phaseidx,nx,nchans,ny)
%FIRTDECIMFILTER   

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/05/23 19:13:18 $

% Quantize input
x = quantizeinput(q,x);

if isreal(p)    
    if isreal(x) && isreal(zi) && isreal(acc),
        % Real output
        % Allocate memory for output
        y = zeros(ny,nchans);
        % Call C-mex
        firtdecimfilter(p,M,x,zi,acc,phaseidx,y);
        zf = zi;
    else
        % Complex output
        [y,zf,acc,phaseidx] = getcmplxoutput(p,M,x,zi,acc,phaseidx,nx,nchans,ny);         
    end
else      
    % Separate real and imaginary parts of the coefficients
    preal = real(p);
    pimag = imag(p);   
    
    lclphaseidx = phaseidx+0;   % force new memory allocation
    lclzi = zi+0;               % force new memory allocation    
    
    
    % Filter input with real part of coefficients (output1)
    [y1,zf1,acc1,lclphaseidx] = getcmplxoutput(preal,M,x,lclzi,acc,lclphaseidx,nx,nchans,ny);    
       
    % Filter input with  imaginary part of coefficients (output2)
    [y2,zf2,acc2,phaseidx] = getcmplxoutput(pimag,M,x,zi,acc,phaseidx,nx,nchans,ny);
    
    % Combine both outputs. Output2 should be multiplied by i. Cannot use
    % COMPLEX function since both outputs could be complex numbers by themselves
    
    y = y1+i*y2;
    zf = zf1+i*zf2;
    acc = acc1+i*acc2;   
    
end



%--------------------------------------------------------------------------
function [y,zf,acc,phaseidx] = getcmplxoutput(p,M,x,zi,acc,phaseidx,nx,nchans,ny)
% GETCMPLXOUTPUT Get complex output

% Complex output
lclphaseidx = phaseidx+0; % Force new memory allocation
% Real part
yr = zeros(ny,nchans);
xr = real(x);
zir = real(zi);
accr = real(acc);
firtdecimfilter(p,M,xr,zir,accr,lclphaseidx,yr);

% Imaginary part
yi = zeros(ny,nchans);
xi = imag(x);
zii = imag(zi);
acci = imag(acc);
firtdecimfilter(p,M,xi,zii,acci,phaseidx,yi);

y = complex(yr,yi);
zf = complex(zir,zii);
acc = complex(accr,acci);


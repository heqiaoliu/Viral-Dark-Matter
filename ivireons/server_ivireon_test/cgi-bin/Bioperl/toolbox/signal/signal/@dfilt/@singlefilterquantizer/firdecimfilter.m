function [y, zf, acc, phaseidx, tapidx] = firdecimfilter(q,M,p,x,zi,acc,phaseidx,tapidx,nx,nchans,ny)
%FIRDECIMFILTER   

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:30:32 $

% Quantize input
x = quantizeinput(q,x);

if isreal(x) && isreal(zi) && isreal(acc),
    % Allocate memory for output 
    y = single(zeros(ny,nchans));
    % Call C-mex
    sfirdecimfilter(p,M,x,zi,acc,phaseidx,tapidx,y);
    zf = zi;
else
    % Complex output
    lclphaseidx = phaseidx+0; % Force new memory allocation;
    lcltapidx = tapidx+0; % Force new memory allocation
    % Real part
    yr = single(zeros(ny,nchans));
    xr = real(x);
    zir = real(zi);
    accr = real(acc);
    sfirdecimfilter(p,M,xr,zir,accr,lclphaseidx,lcltapidx,yr);
    
    % Imaginary part
    yi = single(zeros(ny,nchans));
    xi = imag(x);
    zii = imag(zi);
    acci = imag(acc);
    sfirdecimfilter(p,M,xi,zii,acci,phaseidx,tapidx,yi);
    
    y = complex(yr,yi);
    zf = complex(zir,zii);
    acc = complex(accr,acci);
end




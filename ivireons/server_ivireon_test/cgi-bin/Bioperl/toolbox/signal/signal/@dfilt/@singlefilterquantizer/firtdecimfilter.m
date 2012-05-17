function [y, zf, acc, phaseidx] = firtdecimfilter(q,M,p,x,zi,acc,phaseidx,nx,nchans,ny)
%FIRTDECIMFILTER   

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $ $

% Quantize input
x = quantizeinput(q,x);

if isreal(x) && isreal(zi) && isreal(acc),
    % Allocate memory for output 
    y = single(zeros(ny,nchans));
    % Call C-mex
    sfirtdecimfilter(p,M,x,zi,acc,phaseidx,y);
    zf = zi;
else
    % Complex output
    lclphaseidx = phaseidx+0; % Force new memory allocation
    % Real part
    yr = single(zeros(ny,nchans));
    xr = real(x);
    zir = real(zi);
    accr = real(acc);
    sfirtdecimfilter(p,M,xr,zir,accr,lclphaseidx,yr);
    
    % Imaginary part
    yi = single(zeros(ny,nchans));
    xi = imag(x);
    zii = imag(zi);
    acci = imag(acc);
    sfirtdecimfilter(p,M,xi,zii,acci,phaseidx,yi);
    
    y = complex(yr,yi);
    zf = complex(zir,zii);
    acc = complex(accr,acci);
end



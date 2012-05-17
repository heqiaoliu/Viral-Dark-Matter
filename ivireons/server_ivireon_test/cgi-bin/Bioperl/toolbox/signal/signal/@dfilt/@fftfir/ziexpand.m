function zi = ziexpand(Hd,x,zi)
%ZIEXPAND Expand initial conditions for multiple channels when necessary
%   ZI = ZIEXPAND(Hd, X, ZI) 
%
%   This function is intended to only be used by SUPER_FILTER to expand initial
%   conditions. 
%
%   This should be a private method.   

%   Author: R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2007/12/14 15:08:39 $


error(nargchk(3,3,nargin,'struct'));

[m,ndata] = size(x);
ndata = max(ndata,1);

if size(zi,2) ~= ndata && size(zi,2) ~= 1,
	error(generatemsgid('InvalidDimensions'),'The number of channels of the states must equal the number of channels of the input.');
end

if size(zi,2) == 1,
	zi = zi(:,ones(1,ndata));
end

% Expand the fftcoeffs as well
bfft = Hd.fftcoeffs;
bfft = repmat(bfft(:,1),1,ndata);
Hd.fftcoeffs = bfft;


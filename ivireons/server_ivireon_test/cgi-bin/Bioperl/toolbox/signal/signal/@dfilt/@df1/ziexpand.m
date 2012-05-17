function zi = ziexpand(Hd,x,zi)
%ZIEXPAND Expand initial conditions for multiple channels when necessary
%   ZI = ZIEXPAND(Hd, X, ZI) 
%
%   This function is intended to only be used by SUPER_FILTER to expand initial
%   conditions. 
%
%   This should be a private method.   

%   Author: Thomas A. Bryan, R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 15:07:54 $


error(nargchk(3,3,nargin,'struct'));

[m,ndata] = size(x);
ndata = max(ndata,1);

if ~(isempty(zi) | any(size(zi.Numerator,2) == [ndata,1])),
	error(generatemsgid('InvalidDimensions'),'The number of channels of the states must equal the number of channels of the input.');
end

if ~(isempty(zi) | any(size(zi.Denominator,2) == [ndata,1])),
	error(generatemsgid('InvalidDimensions'),'The number of channels of the denominator states must equal the number of channels of the input.');
end


if size(zi.Numerator,2) == 1,
    zi.Numerator   = zi.Numerator(:,ones(1,ndata));
end

if size(zi.Denominator,2) == 1,
    zi.Denominator = zi.Denominator(:,ones(1,ndata));
end


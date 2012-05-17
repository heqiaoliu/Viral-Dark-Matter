function dnum = todatenum(epochObj)
%TODATENUM Convert a cdfepoch object to a MATLAB datenum.
%   N = TODATENUM(CDFEPOCHOBJ) converts the cdfepoch object into
%   a MATLAB serial date number.  Note that a CDF epoch is the number of
%   milliseconds since 01-Jan-0000 whereas a MATLAB datenum is the number
%   of days since 00-Jan-0000.
%
%   See also CDFEPOCH, CDFWRITE.

%   binky
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:08:14 $

s = size(epochObj);
% Converts the CDF epoch object to a MATLAB datenum
dnum = [epochObj.date]/(24 * 3600000) + 1;
if ~isempty(dnum)
    dnum = reshape(dnum, s);
end
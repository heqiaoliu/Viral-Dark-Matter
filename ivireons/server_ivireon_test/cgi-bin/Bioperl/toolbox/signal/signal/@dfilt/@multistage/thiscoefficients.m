function c = thiscoefficients(Hd)
%THISCOEFFICIENTS Filter coefficients.
%   C = THISCOEFFICIENTS(Hd) returns a cell array of coefficients of
%   discrete-time filter Hd.
%
%   See also DFILT.   

%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:43 $

c = {};
for k=1:length(Hd.Stage)
    c = {c{:}, coefficients(Hd.Stage(k))};
end

function t = isnan(A)
%ISNAN  True for Not-a-Number
%   Refer to the MATLAB ISNAN reference page for more information 
%
%   See also ISNAN

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/12/20 07:12:24 $

% fixed-point or boolean fis can never contain NaN
if isfixed(A) || isboolean(A)
    t = false(size(A));
else
    t = isnan(double(A));
end

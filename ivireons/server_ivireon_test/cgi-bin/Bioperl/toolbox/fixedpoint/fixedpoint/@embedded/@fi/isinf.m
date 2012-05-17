function t = isinf(A)
%ISINF  True for infinite elements
%   Refer to the MATLAB ISINF reference page for more information 
%
%   See also ISINF

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/12/20 07:12:23 $

% fixed-point and boolean fis can never contain inf.
if isfixed(A) || isboolean(A)
    t = false(size(A));
else
    t = isinf(double(A));
end

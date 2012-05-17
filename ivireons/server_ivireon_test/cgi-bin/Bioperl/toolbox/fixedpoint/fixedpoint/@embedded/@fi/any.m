function t = any(A,dim)
%ANY    True if any element of a vector is nonzero
%   Refer to the MATLAB ANY reference page for more information. 
%
%   See also ANY

%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/10/24 19:04:04 $

if nargin<2
  dim = [];
end

if isempty(dim)
  t = any(A~=0);
else
  t = any(A~=0, double(dim));
end

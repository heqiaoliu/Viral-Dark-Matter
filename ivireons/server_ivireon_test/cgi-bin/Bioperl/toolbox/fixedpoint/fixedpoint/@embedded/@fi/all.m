function t = all(A,dim)
%ALL    Determine whether all elements of a vector are nonzero
%   Refer to the MATLAB ALL reference page for more information. 
%
%   See also ALL

%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/10/24 19:04:03 $

if nargin<2
  dim = [];
end

if isempty(dim)
  t = all(A~=0);
else
  t = all(A~=0, double(dim));
end

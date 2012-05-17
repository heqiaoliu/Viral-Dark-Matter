function t = logical(A)
%LOGICAL Convert numeric values to logical
%   Refer to the MATLAB LOGICAL reference page for more information.
% 
%   See also LOGICAL

%   Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 21:33:03 $

if ~isreal(A)
  error('fi:logical:nologicalcomplex',...
        'Complex values cannot be converted to logicals.')
end
t = (A~=0);

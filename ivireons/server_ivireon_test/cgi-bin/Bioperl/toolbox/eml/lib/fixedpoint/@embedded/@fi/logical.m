function t = logical(a)
%LOGICAL Convert numeric values to logical
%   Refer to the MATLAB LOGICAL reference page for more information.
% 

%   Copyright 2004-2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:42:59 $

eml_assert(nargin==1,'Incorrect number of inputs');

if eml_ambiguous_types
  t = eml_not_const(zeros(size(a)));
end

eml_assert(isreal(a),'Complex values cannot be converted to logicals')

t = (a~=0);

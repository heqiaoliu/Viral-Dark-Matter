function Value = fullstring(Value,n)
% Expands [] to vector of '' strings

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:45 $
if isempty(Value)
   Value = repmat({''},[n 1]);
end

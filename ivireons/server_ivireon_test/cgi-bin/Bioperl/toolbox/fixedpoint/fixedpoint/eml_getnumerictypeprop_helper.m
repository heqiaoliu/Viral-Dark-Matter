function [propVal,errmsg] = eml_getnumerictypeprop_helper(T,propName)
% EML helper function that returns the property value of the numerictype T
% for its property PROPNAME    

% Copyright 2006-2010 The MathWorks, Inc.

nargchk(2,2,nargin);
errmsg = ''; propVal = [];
if ~isnumerictype(T)
    error('eml:fi:inputNotNumericType','Input must be an embedded.numerictype');
end
try
    propVal = T.(propName);
catch ME
    errmsg = ME.message;
end
%------------------------------------------------------------------
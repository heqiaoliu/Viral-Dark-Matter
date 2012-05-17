function [propVal,errmsg] = eml_getfimathprop_helper(F,propName)
% EML helper function that returns the property value of the fimath F
% for its property PROPNAME    

% Copyright 2006-2009 The MathWorks, Inc.

nargchk(2,2,nargin);
errmsg = ''; propVal = [];
if ~isfimath(F)
    error('eml:fi:inputNotFimath','Input must be an embedded.fimath');
end
try
    propVal = get(F,propName);
catch ME
    errmsg = ME.message;
end
%------------------------------------------------------------------
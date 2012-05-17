function [propVal err] = eml_scompget(obj, propName)
%Embedded MATLAB Library function.
% safe eml get function for System objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:34:52 $



err = ''; propVal = [];
try
    propVal = feval('get',obj,propName);
catch ME
    err = ME.message;
end

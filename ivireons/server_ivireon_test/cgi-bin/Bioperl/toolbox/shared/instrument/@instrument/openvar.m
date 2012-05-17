function openvar(name, obj)
%OPENVAR Open an instrument object for graphical editing.
%
%   OPENVAR(NAME, OBJ) open an instrument object, OBJ, for graphical 
%   editing. NAME is the MATLAB variable name of OBJ.
%
%   See also INSTRUMENT/SET, INSTRUMENT/GET, INSTRUMENT/PROPINFO,
%   INSTRHELP.
%

%   MP 04-17-01
%   Copyright 1999-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:39:51 $

if ~isa(obj, 'instrument')
    errordlg('OBJ must be an instrument object.', 'Invalid object', 'modal');
    return;
end

if ~isvalid(obj)
    errordlg('The instrument object is invalid.', 'Invalid object', 'modal');
    return;
end

try
    inspect(obj);
catch aException
    errmsg = localFixError(aException);
    errordlg(errmsg, 'Inspection error', 'modal');
end

% *******************************************************************
% Fix the error message.
function out = localFixError(exception)

% Initialize variables.
out = exception.message ; 
% Remove the trailing carriage returns from errmsg.
while out(end) == sprintf('\n')
   out = out(1:end-1);
end


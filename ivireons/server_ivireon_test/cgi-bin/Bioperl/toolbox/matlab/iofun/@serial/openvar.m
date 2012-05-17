function openvar(name, obj) %#ok<INUSL>
%OPENVAR Open a serial port object for graphical editing.
%
%   OPENVAR(NAME, OBJ) open a serial port object, OBJ, for graphical 
%   editing. NAME is the MATLAB variable name of OBJ.
%
%   See also SERIAL/SET, SERIAL/GET.
%

%   MP 04-17-01
%   Copyright 1999-2008 The MathWorks, Inc. 
%   $Revision: 1.6.4.4 $  $Date: 2008/05/19 23:18:22 $

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
    out = localFixMessage(aException.message);
    errordlg(out, 'Inspection error', 'modal');
end

% *******************************************************************
% Fix the error message.
function msg = localFixMessage(msg)

% Initialize variables.

% Remove the trailing carriage returns from errmsg.
while msg(end) == sprintf('\n')
   msg = msg(1:end-1);
end



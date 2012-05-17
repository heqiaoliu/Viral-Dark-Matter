function openvar(name, obj)
%OPENVAR Open a timer object for graphical editing.
%
%    OPENVAR(NAME, OBJ) open a timer object, OBJ, for graphical 
%    editing. NAME is the MATLAB variable name of OBJ.
%
%    See also TIMER/SET, TIMER/GET.
%

%    RDD 03-13-2002
%    Copyright 2002-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2008/03/17 22:17:18 $

if ~isa(obj, 'timer')
    errordlg('OBJ must be an timer object.', 'Invalid object', 'modal');
    return;
end

if ~isvalid(obj)
    errordlg('The timer object is invalid.', 'Invalid object', 'modal');
    return;
end

try
    inspect(obj);
catch exception
    exception = fixexception(exception);
    errordlg(exception.message, 'Inspection error', 'modal');
end
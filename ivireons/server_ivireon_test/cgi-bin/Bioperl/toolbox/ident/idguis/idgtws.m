%SCRIPT FILE IDGTWS
%   Script file that reads the model structure from the workspace.
%   The variable XIDarg defines which model structure to use.

%   L. Ljung 4-4-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2006/06/20 20:08:19 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
XIDnn=get(XID.parest(3),'string');XIDerr=0;
if isempty(XIDnn)
    errordlg('You must supply model orders or a name in the Orders: edit field.','Error Dialog','modal');
    return
end

if strcmp(XIDarg,'arx')
    eval('iduiarx(''estimate'',eval(XIDnn),XIDnn);','XIDerr=1;')
elseif strcmp(XIDarg,'io')
    eval('iduiio(''estimate'',eval(XIDnn),XIDnn);','XIDerr=1;')
elseif strcmp(XIDarg,'ss')
    eval('iduiss(''estimate'',eval(XIDnn));','XIDerr=1;')
end
if XIDerr
    errordlg(['The variable ',XIDnn,' is not on the Model board',...
        'and does not exist in the MATLAB workspace.'],'Error Dialog','modal');
end
clear XIDarg XIDnn goto_ws XIDerr

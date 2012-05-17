function UserChange(obj)
%UserChange  Method for FD meas object

%   Author: T. Krauss
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $

obj = struct(obj);
objud = get(obj.h,'userdata');

switch get(obj.h,'style')
case 'edit'
    str = get(obj.h,'string');
    [val,errstr] = fdutil('fdvalidstr',str,objud.complex,objud.integer,...
                              objud.range,objud.inclusive);
    if isempty(errstr)
        objud.lastvalue = objud.value;
        objud.value = val;
        set(obj.h,'userdata',objud)
        set(obj.h,'string',fdutil('formattedstring',obj))
        if ~isempty(objud.callback)
            try
                evalin('base',objud.callback);
            catch ME
                errstr = sprintf('Error in evaluating callback:\n%s',ME.message);
                msgbox(errstr,'Error','error','modal')
            end
        end
    else
        msgbox(errstr,'Error','error','modal')
        set(obj.h,'string',fdutil('formattedstring',obj))
    end
    
otherwise
    warning(generatemsgid('GUIWarn'),'No support for this style of measurement object yet')
end

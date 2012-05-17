function private_set_string(hThis,str)

% Copyright 2004 The MathWorks, Inc.

hTextbox = get(hThis,'TextBoxHandle');
if ishandle(hTextbox)
   set(hTextbox,'String',str);
end
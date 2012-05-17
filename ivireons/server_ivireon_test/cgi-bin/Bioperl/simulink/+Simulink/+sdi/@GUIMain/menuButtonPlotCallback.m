function menuButtonPlotCallback(this, s, e, menuButton, toggleButton, fHandle)
    % Copyright 2010 The MathWorks, Inc.

    UT = Simulink.sdi.Util;
    onOff  = UT.BoolToOnOff(~strcmp(get(menuButton, 'checked'),'on'));
    set(menuButton, 'checked', onOff)
    set(toggleButton, 'state',onOff);
    
    % check if added argument is passed
    sz = length(fHandle);
    
    if (sz == 1)
        fHandle(s,e);    
    elseif (sz == 2)
        func = fHandle{1};
        arg = fHandle{2};
        func(s,e, arg);
    end
end
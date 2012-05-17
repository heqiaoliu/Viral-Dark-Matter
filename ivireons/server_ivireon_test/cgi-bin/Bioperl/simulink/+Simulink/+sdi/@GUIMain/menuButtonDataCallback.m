function menuButtonDataCallback(this, s, e)

%   Copyright 2010 The MathWorks, Inc.

    UT = Simulink.sdi.Util;
    onOff  = UT.BoolToOnOff(~strcmp(get(this.dataMenuRecord, 'checked'...
                            ),'on'));    
    set(this.ToolbarButtonRecord, 'state',onOff); 
    this.ToolbarButtonRecordCallback(s, e);            
end
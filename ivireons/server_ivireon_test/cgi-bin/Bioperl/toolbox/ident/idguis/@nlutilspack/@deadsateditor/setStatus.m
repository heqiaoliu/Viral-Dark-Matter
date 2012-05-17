function setStatus(this, msg,status)
%set status string

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:04:50 $

if status
    pColor = java.awt.Color(0.4039,0.8000,0.4039);
else
    pColor = java.awt.Color(0.9961,0.4353,0.2784);
end
javaMethodEDT('setBackground',this.Handles.StatusLabel,pColor);
    
javaMethodEDT('setText',this.Handles.StatusLabel,msg);

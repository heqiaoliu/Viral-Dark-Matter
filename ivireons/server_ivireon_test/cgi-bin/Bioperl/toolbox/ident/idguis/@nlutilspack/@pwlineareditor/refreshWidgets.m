function refreshWidgets(this)
% refresh widgets as a result of initialization or radio button callback

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:05:09 $

if this.isXonly
     if this.Handles.YEdit.isEnabled
        javaMethodEDT('setEnabled',this.Handles.YEdit,false);
    end
else
     if ~this.Handles.YEdit.isEnabled
        javaMethodEDT('setEnabled',this.Handles.YEdit,true);
    end
end

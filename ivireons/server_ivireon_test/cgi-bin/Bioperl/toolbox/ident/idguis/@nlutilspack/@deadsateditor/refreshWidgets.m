function refreshWidgets(this)
% refresh widgets as a result of initialization or radio button callback

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:04:49 $

if this.isTwo
    if this.Handles.rUp.isEnabled
        javaMethodEDT('setEnabled',this.Handles.rUp,false);
    end
    if this.Handles.rLow.isEnabled
        javaMethodEDT('setEnabled',this.Handles.rLow,false);
    end
    if ~this.Handles.XmaxEdit.isEnabled
        javaMethodEDT('setEnabled',this.Handles.XmaxEdit,true);
    end
    if ~this.Handles.XminEdit.isEnabled
        javaMethodEDT('setEnabled',this.Handles.XminEdit,true);
    end
    LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
    LocalSetText(this.Handles.XminEdit, this.getStr('low'));
else
    if ~this.Handles.rUp.isEnabled
        javaMethodEDT('setEnabled',this.Handles.rUp,true);
    end
    if ~this.Handles.rLow.isEnabled
        javaMethodEDT('setEnabled',this.Handles.rLow,true);
    end
    if this.isUp
        LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
        LocalSetText(this.Handles.XminEdit, '-Inf');
        if ~this.Handles.XmaxEdit.isEnabled
            javaMethodEDT('setEnabled',this.Handles.XmaxEdit,true);
        end
        if this.Handles.XminEdit.isEnabled
            javaMethodEDT('setEnabled',this.Handles.XminEdit,false);
        end
    else
        LocalSetText(this.Handles.XmaxEdit, 'Inf');
        LocalSetText(this.Handles.XminEdit, this.getStr('low'));
        if this.Handles.XmaxEdit.isEnabled
            javaMethodEDT('setEnabled',this.Handles.XmaxEdit,false);
        end
        if ~this.Handles.XminEdit.isEnabled
            javaMethodEDT('setEnabled',this.Handles.XminEdit,true);
        end
    end
end

%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);

function refresh(this, isInput, Index)
% Configure the options on the dialog

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:04:48 $

% update parameters
m = this.Panel.NlhwModel;
this.Parameters.Index = Index;
this.Parameters.isInput = isInput;

if isInput
    nlobj = this.Panel.NlhwModel.InputNonlinearity(Index);
    str0 = sprintf('input channel: %s',m.uname{Index});
else
    nlobj = this.Panel.NlhwModel.OutputNonlinearity(Index);
    str0 = sprintf('output channel: %s',m.yname{Index});
end

if this.isSat
    LI = nlobj.LinearInterval;
else
    LI = nlobj.ZeroInterval;
end

this.Parameters.low = LI(1);
this.Parameters.up = LI(2);

% update instruction string
istr = sprintf('Specify %s limits on the %s. Enter [] to use default values.',...
    this.getNLName,str0);

LocalSetText(this.Handles.iLabel,istr);

% update GUI widgets
if isinf(this.Parameters.up) && ~isinf(this.Parameters.low)
    this.isTwo = false;
    this.isUp = false;
    javaMethodEDT('doClick',this.Handles.rOne);
    javaMethodEDT('doClick',this.Handles.rLow);
elseif ~isinf(this.Parameters.up) && isinf(this.Parameters.low)
    this.isTwo = false;
    this.isUp = true;
    javaMethodEDT('doClick',this.Handles.rOne);
    javaMethodEDT('doClick',this.Handles.rUp);
else
    this.isTwo = true;
    javaMethodEDT('doClick',this.Handles.rTwo);
end

LocalSetText(this.Handles.StatusLabel,'');
this.refreshWidgets;
javaMethodEDT('show',this.Handles.Dialog);

%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);

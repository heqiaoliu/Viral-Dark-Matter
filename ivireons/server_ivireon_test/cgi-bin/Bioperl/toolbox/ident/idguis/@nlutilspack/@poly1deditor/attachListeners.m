function attachListeners(this)
% attach listeners to all push buttons in poly1d editor dialog

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:13:40 $


h = handle(this.Handles.OKBtn, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalOK this};

h = handle(this.Handles.CancelBtn, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalCancel this};

h = handle(this.Handles.Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalCancel this};

h = handle(this.Handles.ApplyBtn, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalApply this};

h = handle(this.Handles.HelpBtn, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalHelp};


%--------------------------------------------------------------------------
function LocalApply(es,ed,this)
% callback for apply button pressed

[status,msg] = LocalAttemptApply(this);

if status
    pColor = java.awt.Color(0.4039,0.8000,0.4039);
    str = 'Coefficient values updated successfully.';
else
    iderrordlg(msg, 'Invalid Coefficient Values', this.Handles.Dialog);
    pColor = java.awt.Color(0.9961,0.4353,0.2784);
    str = 'Coefficient values failed to update.';
end

javaMethodEDT('setBackground',this.Handles.StatusLabel,pColor);
LocalSetText(this.Handles.StatusLabel,str);

%--------------------------------------------------------------------------
function LocalCancel(es,ed,this)
% callback for cancel buttom pressed

javaMethodEDT('setVisible',this.Handles.Dialog,false);

%--------------------------------------------------------------------------
function LocalOK(es,ed,this)
% callback for OK button pressed

[status,msg] = LocalAttemptApply(this);
if status
    % close the dialog
    LocalCancel(es,ed,this);
else
    iderrordlg(msg, 'Invalid Coefficient Values', this.Handles.Dialog);
    LocalSetText(this.Handles.StatusLabel,'Initial values failed to update.');
end

%--------------------------------------------------------------------------
function [val,failed,msg] = LocalProcessCoeff(this,Type)
% process the entries in the coefficient edit box

failed = false; %status of failure

es = this.Handles.CoeffEdit;
msg0 = sprintf('Coefficients should be specified as a row vector of %d real and finite values.',...
    this.Degree+1);
msg = '';
vstr = char(es.getText);
val = [];
if ~isempty(vstr)
    try
        val = evalin('base',vstr);
        if isempty(val)
            val = [];
        elseif ~(isrealvec(val) && (length(val)==this.Degree+1) ...
                && all(isfinite(val)))
            failed = true;
            msg = msg0;
        end
    catch
        failed = true;
        msg = msg0;
        val = this.Parameters.Coefficients;
    end
end

%--------------------------------------------------------------------------
function LocalUpdateModelInPanel(this)
% update nonlinearity object in IDNLHW panel

C = this.Parameters.Coefficients;
Panel = this.Parameters.Panel;
m = Panel.NlhwModel;
Ind = this.Parameters.Index;

if this.Parameters.isInput
    Type = 'InputNonlinearity';
else
    Type = 'OutputNonlinearity';
end

if isempty(C)
    C = [];
end

if Panel.isSingleInput
    m.(Type).Coefficients = C;
else
    m.(Type)(Ind).Coefficients = C;
end

Panel.updateModel(m);
nlbbpack.sendModelChangedEvent('idnlhw');

%--------------------------------------------------------------------------
function LocalHelp(varargin)
% show dialog help

iduihelp('poly1dcoeffeditor.htm',...
    'Help: Coefficient values for One-dimensional Polynomial');

%--------------------------------------------------------------------------
function [status,msg] = LocalAttemptApply(this)
% try to apply entered changes when Apply or OK button is pressed

status = false;
%msg = '';

try
    [val,st,msg] = LocalProcessCoeff(this);
    if st
        LocalSetText(this.Handles.CoeffEdit, this.getStr);
        return;
    end
    this.Parameters.Coefficients = val(:).';
    LocalSetText(this.Handles.CoeffEdit, this.getStr);
    
    LocalUpdateModelInPanel(this);
    status = true;
catch E
    status = false;
    msg = idlasterr(E);
end
%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);

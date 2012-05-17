function attachListeners(this)
% attach listeners to all radio and push buttons

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:13:31 $

h = handle(this.Handles.rTwo, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRadioSelectionCallback this 'two'};

h = handle(this.Handles.rOne, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRadioSelectionCallback this 'one'};

h = handle(this.Handles.rUp, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRadioSelectionCallback this 'up'};

h = handle(this.Handles.rLow, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRadioSelectionCallback this 'low'};

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
function LocalRadioSelectionCallback(es, ed, this, Type)

switch Type
    case 'two';
        this.isTwo = true;
    case 'one'
        this.isTwo = false;
    case 'up'
        this.isUp = true;
    case 'low'
        this.isUp = false;
end

this.refreshWidgets;

%--------------------------------------------------------------------------
function LocalApply(es, ed, this)

[status,msg] = LocalAttemptApply(this);

if status
    this.setStatus(sprintf('Initial guess values for %s updated successfully.',...
        this.getNLName),status);
else
    iderrordlg(msg, 'Invalid Limits', this.Handles.Dialog);
    this.setStatus(sprintf('Initial guess values for %s failed to update.',...
        this.getNLName),status);
end

%--------------------------------------------------------------------------
function LocalCancel(es,ed,this)
% hide dialog

javaMethodEDT('setVisible',this.Handles.Dialog,false);

%--------------------------------------------------------------------------
function LocalOK(es,ed,this)

[status,msg] = LocalAttemptApply(this);
if status
    % close the dialog
    LocalCancel(es,ed,this);
else
    iderrordlg(msg, 'Invalid Limits', this.Handles.Dialog);
    this.setStatus(sprintf('Initial guess values for %s failed to update.',...
        this.getNLName),status);
end
%--------------------------------------------------------------------------
function [val,failed,msg] = LocalProcessBreakPoints(this,Type)
% process the entries in the edit boxes

failed = false; %status of failure
msg = '';

if strcmp(Type,'up')
    es = this.Handles.XmaxEdit;
else
    es = this.Handles.XminEdit;
end

vstr = char(es.getText);
val = [];
if ~isempty(vstr)
    try
        val = evalin('base',vstr);
        if isempty(val)
            val = [];
        elseif ~isscalar(val) || ~isfloat(val) || (strcmp(Type,'up') && (val==-Inf)) || ...
                (strcmp(Type,'low') && (val==Inf))
            ctrlMsgUtils.error('Ident:idguis:invalidBreakPoints',this.getNLName);
        elseif isnan(val)
            val = [];
        end
    catch E
        failed = true;
        msg = idlasterr(E);
        val = this.Parameters.(Type);
    end
end

%--------------------------------------------------------------------------
function [stf,msg] = LocalUpdateModelInPanel(this)

msg = '';
stf = true;
up = this.Parameters.up;
low = this.Parameters.low;

if isempty(up)
    up = NaN;
end

if isempty(low)
    low = NaN;
end

Panel = this.Panel;
m = Panel.NlhwModel;
Ind = this.Parameters.Index;

if this.Parameters.isInput
    Type = 'InputNonlinearity';
else
    Type = 'OutputNonlinearity';
end

if this.isSat
    PropName = 'LinearInterval';
else
    PropName = 'ZeroInterval';
end

try
    if Panel.isSingleInput
        m.(Type).(PropName) = [low,up];
    else
        m.(Type)(Ind).(PropName) = [low,up];
    end
    nlbbpack.sendModelChangedEvent('idnlhw');
    Panel.updateModel(m);
catch E
    stf = false;
    msg = idlasterr(E);
end


%--------------------------------------------------------------------------
function LocalHelp(varargin)

iduihelp('nlinitvalueeditor.htm',...
    'Help: Initial Values for Saturation, Dead Zone and Piecewise Linear');

%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);

%-------------------------------------------------------------------------
function [status,msg] = LocalAttemptApply(this)
% try to apply entered changes when Apply or OK button is pressed

status = false;
%msg = '';
%xmin = []; xmamx = [];
if this.isTwo
    [valmax,st1,msg] =  LocalProcessBreakPoints(this,'up');
    if st1 
        LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
        return;
    end
    
    [valmin,st2,msg] =  LocalProcessBreakPoints(this,'low');
    if st2
        LocalSetText(this.Handles.XminEdit, this.getStr('low'));
        return;
    end

    if valmax<=valmin
        msg = sprintf('Upper limit of %s must be greater than the lower limit.',...
            this.getNLName);
        LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
        LocalSetText(this.Handles.XminEdit, this.getStr('low'));
        return;
    end

    this.Parameters.up = valmax;
    this.Parameters.low = valmin;
    LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
    LocalSetText(this.Handles.XminEdit, this.getStr('low'));
else
    if this.isUp
        this.Parameters.low = -Inf;
        [valmax,st,msg] =  LocalProcessBreakPoints(this,'up');
        if st
            LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
            return
        end
        this.Parameters.up = valmax;
        LocalSetText(this.Handles.XmaxEdit, this.getStr('up'));
    else
        this.Parameters.up = Inf;
        [valmin,st,msg] =  LocalProcessBreakPoints(this,'low');
        if st
            LocalSetText(this.Handles.XminEdit, this.getStr('low'));
            return
        end
        this.Parameters.low = valmin;
        LocalSetText(this.Handles.XminEdit, this.getStr('low'));
    end
end

[status,msg] = LocalUpdateModelInPanel(this);

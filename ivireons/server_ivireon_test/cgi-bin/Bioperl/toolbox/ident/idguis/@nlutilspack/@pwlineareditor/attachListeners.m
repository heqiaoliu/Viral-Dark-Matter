function attachListeners(this)
% attach listeners to all radio and push buttons

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2008/10/31 06:13:42 $

% radio buttons
h = handle(this.Handles.rx, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRadioSelectionCallback this 'x'};

h = handle(this.Handles.ry, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRadioSelectionCallback this 'y'};

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
function LocalRadioSelectionCallback(es,ed,this,Type)
% radio button callback

if strcmpi(Type,'x')
    this.isXonly = true;
else
    this.isXonly = false;
end

this.refreshWidgets;

%--------------------------------------------------------------------------
function LocalApply(es,ed,this)

[status,msg] = LocalAttemptApply(this);

if status
    pColor = java.awt.Color(0.4039,0.8000,0.4039);
    str = 'Initial values updated successfully.';
else
    iderrordlg(msg, 'Invalid Initial Values', this.Handles.Dialog);
    pColor = java.awt.Color(0.9961,0.4353,0.2784);
    str = 'Initial values failed to update.';
end

javaMethodEDT('setBackground',this.Handles.StatusLabel,pColor);
LocalSetText(this.Handles.StatusLabel,str);

%--------------------------------------------------------------------------
function LocalCancel(es,ed,this)

javaMethodEDT('setVisible',this.Handles.Dialog,false);

%--------------------------------------------------------------------------
function LocalOK(es,ed,this)

[status,msg] = LocalAttemptApply(this);
if status
    % close the dialog
    LocalCancel(es,ed,this);
else
    iderrordlg(msg, 'Invalid Initial Values', this.Handles.Dialog);
    LocalSetText(this.Handles.StatusLabel,'Initial values failed to update.');
end

%--------------------------------------------------------------------------
function [val,failed,msg] = LocalProcessBreakPoints(this,Type)
% process the entries in the edit boxes

failed = false; %status of failure

if strcmp(Type,'x')
    es = this.Handles.XEdit;
    msg0 = sprintf('Break points should be a vector of %d unique, real and finite values.',...
        this.NumUnits);
else
    es = this.Handles.YEdit;
    msg0 = sprintf('Nonlinearity values should be a vector of %d real and finite values.',...
        this.NumUnits);
end

msg = '';
vstr = char(es.getText);
val = [];
if ~isempty(vstr)
    try
        val = evalin('base',vstr);
        if isempty(val)
            val = [];
        elseif ~(isrealvec(val) && (length(val)==this.NumUnits) ...
                && all(isfinite(val))) ||...
                (strcmp(Type,'x') &&  ~isequal(length(unique(val)),length(val)))
            failed = true;
            msg = msg0;
        end
    catch
        failed = true;
        msg = msg0;
        val = this.Parameters.(Type);
    end
end

%--------------------------------------------------------------------------
function LocalUpdateModelInPanel(this)

BP = [this.Parameters.x;this.Parameters.y];

Panel = this.Parameters.Panel;
m = Panel.NlhwModel;
Ind = this.Parameters.Index;

if this.Parameters.isInput
    Type = 'InputNonlinearity';
else
    Type = 'OutputNonlinearity';
end

if Panel.isSingleInput
    if isempty(BP)
        numun = m.(Type).NumberOfUnits;
        m.(Type).BreakPoints = [];
        m.(Type).NumberOfUnits = numun;
    else
        m.(Type).BreakPoints = BP;
    end
else
    if isempty(BP)
        numun = m.(Type)(Ind).NumberOfUnits;
        m.(Type)(Ind).BreakPoints = [];
        m.(Type)(Ind).NumberOfUnits = numun;
    else
        m.(Type)(Ind).BreakPoints = BP;
    end
end

nlbbpack.sendModelChangedEvent('idnlhw');
Panel.updateModel(m);

%--------------------------------------------------------------------------
function LocalHelp(varargin)

iduihelp('nlinitvalueeditor.htm',...
    'Help: Initial Values for Saturation, Dead Zone and Piecewise Linear');

%--------------------------------------------------------------------------
function [status,msg] = LocalAttemptApply(this)
% try to apply entered changes when Apply or OK button is pressed

status = false;
%msg = '';
try
    if this.isXonly
        this.Parameters.y = [];
        [val,st,msg] = LocalProcessBreakPoints(this,'x');
        if st
            LocalSetText(this.Handles.XEdit, this.getStr('x'));
            return;
        end
        this.Parameters.x = val(:).';
        LocalSetText(this.Handles.XEdit, this.getStr('x'));
    else
        [valx,st1,msg] = LocalProcessBreakPoints(this,'x');
        if ~st1
            [valy,st2,msg] = LocalProcessBreakPoints(this,'y');
            if st2
                LocalSetText(this.Handles.YEdit, this.getStr('y'));
                return;
            end

        else
            LocalSetText(this.Handles.XEdit, this.getStr('x'));
            return;
        end

        if isempty(valx) && ~isempty(valy)
            msg= 'If nonlinearity values are specified, the break point locations must also be specified as a non-empty vector.';
            LocalSetText(this.Handles.XEdit, this.getStr('x'));
            return;
        else
            this.Parameters.x = valx(:).';
            this.Parameters.y = valy(:).';
            LocalSetText(this.Handles.XEdit, this.getStr('x'));
            LocalSetText(this.Handles.YEdit, this.getStr('y'));
        end
    end

    LocalUpdateModelInPanel(this);
    status = true;
catch E
    status = false;
    msg = idlasterr(E);
end
%-------------------------------------------------------------------------
function LocalSetText(component, string)

javaMethodEDT('setText',component,string);

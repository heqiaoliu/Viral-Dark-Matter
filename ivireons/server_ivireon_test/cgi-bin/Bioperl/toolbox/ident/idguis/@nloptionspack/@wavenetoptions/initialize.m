function initialize(this)
% initialize wavenetoptions object's properties.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:13:24 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% get handles to (java) controls
jh = this.jMainPanel; %main java panel for this object
this.jAdvancedButton = jh.getMoreOptionsButton;
this.jButtonGroup = jh.getButtonGroup;
this.jNumUnitsEdit = jh.getNumUnitsEdit;
this.jAutoRadio = jh.getAutoRadio;
this.jUserDefinedRadio = jh.getUserDefinedRadio;
this.jChooseInteractivelyRadio = jh.getChooseInteractivelyRadio;

% create an advanced options object for wavenet
this.AdvancedOptions = nloptionspack.advancedwavenet(this); 

% attach listeners
h = handle(this.jAdvancedButton,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalShowPropertyInspector(this));

h = handle(this.jNumUnitsEdit,'CallbackProperties');
L2 = handle.listener(h,'ActionPerformed', @(x,y)LocalNumUnitsUpdated(y,this));
L3 = handle.listener(h,'FocusLost', @(x,y)LocalNumUnitsUpdated(y,this));

%radio buttons
% {
h = handle(this.jAutoRadio,'CallbackProperties');
L4 = handle.listener(h,'ActionPerformed', @(x,y)LocalRadioSelectionChanged(y,this));
h = handle(this.jUserDefinedRadio,'CallbackProperties');
L5 = handle.listener(h,'ActionPerformed', @(x,y)LocalRadioSelectionChanged(y,this));
h = handle(this.jChooseInteractivelyRadio,'CallbackProperties');
L6 = handle.listener(h,'ActionPerformed', @(x,y)LocalRadioSelectionChanged(y,this));
%}

this.Listeners = [L1,L2,L3,L4,L5,L6];

%--------------------------------------------------------------------------
function LocalShowPropertyInspector(this)

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the object in the property inspector
p = NonlinPropInspector.getInstance;
optionsobj = this.AdvancedOptions;
nloptionspack.setAdvancedProperties(optionsobj);
p.getPropertyViewPanel.setObject(java.lang.Object);
p.getPropertyViewPanel.setObject(optionsobj);

% show the property inspector
%awtinvoke(p,'setVisible(Z)',true);
p.showInspector('nonlin','Wavelet Network');

%--------------------------------------------------------------------------
function LocalNumUnitsUpdated(ed,this)

%sanity check on radio button selection
if ~strcmp(char(this.jButtonGroup.getSelection.getActionCommand),'userdefined')
    %disp('Wrong radio button selected (should be user-defined).');
    return;
end

val = ed.Source.Text;

try
    val = evalin('base',val); %evaluated the entered expression
    if ~isposintscalar(val)
        ctrlMsgUtils.error('Ident:idguis:invalidNumUnits')
    end
    this.Object.NumberOfUnits = val; 
    
    %update string in GUI
    this.jMainPanel.setNumUnits(int2str(val));
    nlbbpack.sendModelChangedEvent('idnlarx');
catch E
    errordlg(idlasterr(E),'Invalid Value','modal');
    oldval = this.Object.NumberOfUnits;
    if strcmpi(oldval,'auto')
        oldval = 10;
    end
    %disp(lasterr) % diagnostics only
    this.jMainPanel.setNumUnits(java.lang.String(int2str(oldval)));
end

%--------------------------------------------------------------------------
function LocalRadioSelectionChanged(y,this)
% update this.Object for numberofunits

val = char(y.Source.ActionCommand);

switch val
    case {'auto','interactive'}
        this.Object.NumberOfUnits = val;
    case 'userdefined'
        numval = str2double(char(this.jNumUnitsEdit.getText));
        this.Object.NumberOfUnits = numval;
    otherwise
        %disp('Invalid value for radio button action command (wavenetoptions/initialize)')
end
nlbbpack.sendModelChangedEvent('idnlarx');
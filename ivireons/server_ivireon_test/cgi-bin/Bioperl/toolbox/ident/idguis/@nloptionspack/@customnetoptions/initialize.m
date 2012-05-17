function initialize(this)
%Initialize customnetoptions object's properties.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:13:17 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% get handles to (java) controls
jh = this.jMainPanel; %main java panel for this object
this.jImportButton = jh.getImportButton;
this.jUnitFcnName = jh.getUnitFcnName;
this.jNumUnitsEdit = jh.getNumUnitsEdit;

% attach listeners
h = handle(this.jImportButton,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalImportUnitFcn(this));

h = handle(this.jNumUnitsEdit,'CallbackProperties');
L2 = handle.listener(h,'ActionPerformed', @(x,y)LocalNumUnitsUpdated(y,this));
L3 = handle.listener(h,'FocusLost', @(x,y)LocalNumUnitsUpdated(y,this));

this.Listeners = [L1,L2,L3];

%--------------------------------------------------------------------------
function LocalImportUnitFcn(this)
% launch dialog that allows unit function specification

if ~idIsValidHandle(this.UnitFcnDlg)
    nlgui = nlutilspack.getNLBBGUIInstance;
    this.UnitFcnDlg = nlutilspack.customnetunitfcndialog;
    this.UnitFcnDlg.initialize(nlgui.jGuiFrame,{@LocalProcessUnitFunction this}, this.Object);
else
    this.UnitFcnDlg.refresh({@LocalProcessUnitFunction this},this.Object);
end

javaMethodEDT('setVisible',this.UnitFcnDlg.Frame,true);

%--------------------------------------------------------------------------
function LocalNumUnitsUpdated(ed,this)

val = ed.Source.Text;
Ind = this.NlarxPanel.getCurrentOutputIndex;
m = this.NlarxPanel.NlarxModel;

try
    val = evalin('base',val); %evaluate the entered expression
    if ~isposintscalar(val)
        ctrlMsgUtils.error('Ident:idguis:invalidNumUnits')
    end
    m.Nonlinearity(Ind).NumberOfUnits = val;
    this.NlarxPanel.updateModel(m);

    %update string in GUI
    this.jMainPanel.setNumUnits(int2str(val));
    nlbbpack.sendModelChangedEvent('idnlarx');
catch E
    errordlg(idlasterr(E),'Invalid Value','modal');
    oldval = m.Nonlinearity(Ind).NumberOfUnits;
    if strcmpi(oldval,'auto')
        oldval = 10;
    end
    %disp(lasterr) % diagnostics only
    this.jMainPanel.setNumUnits(java.lang.String(int2str(oldval)));
end

%--------------------------------------------------------------------------
function LocalProcessUnitFunction(this,fcn,filename)
% update unit function info

this.Object.UnitFcn = fcn;
this.jMainPanel.setUnitFcn(filename);

nlbbpack.sendModelChangedEvent('idnlarx');


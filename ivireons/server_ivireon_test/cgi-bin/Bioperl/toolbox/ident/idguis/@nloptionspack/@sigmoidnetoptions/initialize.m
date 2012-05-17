function initialize(this)
%Initialize sigmoidnetoptions object's properties.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 06:13:22 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% get handles to (java) controls
jh = this.jMainPanel; %main java panel for this object
this.jNumUnitsEdit = jh.getNumUnitsEdit;

h = handle(this.jNumUnitsEdit,'CallbackProperties');
L2 = handle.listener(h,'ActionPerformed', @(x,y)LocalNumUnitsUpdated(y,this));
L3 = handle.listener(h,'FocusLost', @(x,y)LocalNumUnitsUpdated(y,this));

this.Listeners = [L2,L3];

%--------------------------------------------------------------------------
function LocalNumUnitsUpdated(ed,this)

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

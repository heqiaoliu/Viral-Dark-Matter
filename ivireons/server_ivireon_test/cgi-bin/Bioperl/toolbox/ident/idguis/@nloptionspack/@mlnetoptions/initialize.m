function initialize(this)
%Initialize mlnetoptions object's properties.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:04:29 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% get handles to (java) controls
jh = this.jMainPanel; %main java panel for this object
this.jImportButton = jh.getImportButton;
%this.jNetworkObjectName = jh.getNetworkObjectName;
%this.NetworkImportdlg = nlutilspack.networkimportdialog;
%this.NetworkImportdlg.initialize(this);

if isa(this.Object.Network,'network')
    oldval = this.NetworkName;
    if isempty(oldval)
        oldval = '<Existing object>'; %jh.getNetworkName;    
    end
else
    oldval = '<Import from Workspace or MAT file>';
end
%disp(lasterr) % diagnostics only
this.jMainPanel.setNetworkObject(java.lang.String(oldval));

% attach listeners
h = handle(this.jImportButton,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalImportNetwork(this));

this.Listeners = L1;

%--------------------------------------------------------------------------
function LocalImportNetwork(this)

if isempty(this.NetworkImportdlg) || ~ishandle(this.NetworkImportdlg)
    nlgui = nlutilspack.getNLBBGUIInstance;
    this.NetworkImportdlg = nlutilspack.varimportdialog;
    this.NetworkImportdlg.initialize(nlgui.jGuiFrame,this,'network');
end
this.NetworkImportdlg.workbrowser.open([1 NaN; NaN 1]);
javaMethodEDT('setVisible',this.NetworkImportdlg.Frame,true);

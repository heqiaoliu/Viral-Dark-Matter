function refreshPanelWidgets(this)
% refresh panel widget states to agree with the idnlarx model's nonlin
% options data

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:50:34 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the contents of the panel by reading data from idnlarx model
Ind = this.NlarxPanel.getCurrentOutputIndex;

% include linear model checkbox update
% use setSelected rather than doClick because no events should be fired.
m = this.NlarxPanel.NlarxModel;

%this.Listeners.Enabled = 'off';

nl =  m.Nonlinearity(Ind); %current nonlinearity
%nl = initreset(nl);

numu = nl.NumberOfUnits;
if ischar(numu)
    javaMethodEDT('setSelected',this.jAutoRadio,true);
    if this.jNumUnitsEdit.isEnabled
        javaMethodEDT('setEnabled',this.jNumUnitsEdit,false);
    end
else
    %numeric
    %L = find(this.Listeners,'SourceObject',handle(this.jUserDefinedRadio,'callbackproperties'));
    this.jMainPanel.setNumUnits(java.lang.String(int2str(numu))); % event thread method
    javaMethodEDT('setSelected',this.jUserDefinedRadio,true);
    if ~this.jNumUnitsEdit.isEnabled
        javaMethodEDT('setEnabled',this.jNumUnitsEdit,true);
    end
end

%this.Listeners.Enabled = 'on';

% update the underlying Object property:
this.Object = nl;

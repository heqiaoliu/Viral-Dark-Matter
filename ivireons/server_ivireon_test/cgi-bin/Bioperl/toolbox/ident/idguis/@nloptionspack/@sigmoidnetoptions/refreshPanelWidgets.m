function refreshPanelWidgets(this)
% refresh panel widget states to agree with the idnlarx model's nonlin
% options data

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:04:33 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the contents of the panel by reading data from idnlarx model
Ind = this.NlarxPanel.getCurrentOutputIndex;

% include linear model checkbox update
% use setSelected rather than doClick because no events should be fired.
m = this.NlarxPanel.NlarxModel;

linval = m.Nonlinearity(Ind).LinearTerm;
if strcmpi(linval,'on')
    javaMethodEDT('setSelected',this.NlarxPanel.jIncludeLinearModelCheckBox,true);
else
    javaMethodEDT('setSelected',this.NlarxPanel.jIncludeLinearModelCheckBox,false);
end

nl =  m.Nonlinearity(Ind); %current nonlinearity
%nl = initreset(nl); 

numu = nl.NumberOfUnits;

%numeric
% switch off listener
%L = find(this.Listeners,'SourceObject',handle(this.jUserDefinedRadio,'callbackproperties'));
this.jMainPanel.setNumUnits(java.lang.String(int2str(numu))); % event thread method

% update the underlying Object property:
this.Object = nl;
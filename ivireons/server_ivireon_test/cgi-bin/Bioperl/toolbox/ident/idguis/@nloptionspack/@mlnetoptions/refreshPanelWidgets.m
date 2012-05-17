function refreshPanelWidgets(this)
% refresh panel widget states to agree with the idnlarx model's nonlin
% options data

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:04:30 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the contents of the panel by reading data from idnlarx model
Ind = this.NlarxPanel.getCurrentOutputIndex;
m = this.NlarxPanel.NlarxModel;

nl =  m.Nonlinearity(Ind); %current nonlinearity
%nl = initreset(nl);
net = nl.Network;

%L = find(this.Listeners,'SourceObject',handle(this.jUserDefinedRadio,'callbackproperties'));
if isa(net,'network')
    name = this.NetworkName;
    if isempty(name)
       name = '<Existing object>'; 
    end    
else
    name = '<Import from Workspace or MAT file>';
end

this.jMainPanel.setNetworkObject(java.lang.String(name)); % event thread method
this.Object = nl;

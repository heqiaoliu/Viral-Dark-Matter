function refreshPanelWidgets(this)
% refresh panel widget states to agree with the idnlarx model's nonlin
% options data

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:54:29 $

Ind = this.NlarxPanel.getCurrentOutputIndex;
m = this.NlarxPanel.NlarxModel;
nl =  m.Nonlinearity(Ind); %current nonlinearity
%nl = initreset(nl); 

this.Object = nl;

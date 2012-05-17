function refreshPanelWidgets(this)
% refresh panel widget states to agree with the idnlarx model's nonlin
% options data

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/03/22 03:48:56 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the contents of the panel by reading data from idnlarx model
Ind = this.NlarxPanel.getCurrentOutputIndex;

% include linear model checkbox update
% use setSelected rather than doClick because no events should be fired.
m = this.NlarxPanel.NlarxModel;

nl =  m.Nonlinearity(Ind); %current nonlinearity
%nl = initreset(nl); 

linval = nl.LinearTerm;
if strcmpi(linval,'on')
    javaMethodEDT('setSelected',this.NlarxPanel.jIncludeLinearModelCheckBox,true);
else
    javaMethodEDT('setSelected',this.NlarxPanel.jIncludeLinearModelCheckBox,false);
end

% set unit fcn
uf = nl.UnitFcn;
if isempty(uf)
    filename = '<Specify function handle or name of an MATLAB or MEX file>';
else
    filename = func2str(uf);
end
this.jMainPanel.setUnitFcn(filename);

this.Object = nl;

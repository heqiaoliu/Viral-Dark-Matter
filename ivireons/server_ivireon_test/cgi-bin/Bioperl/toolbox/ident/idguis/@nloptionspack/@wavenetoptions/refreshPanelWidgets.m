function refreshPanelWidgets(this)
% refresh panel widget states to agree with the idnlarx model's nonlin
% options data 

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2009/03/09 19:14:17 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the contents of the panel by reading data from idnlarx model
Ind = this.NlarxPanel.getCurrentOutputIndex;
m = this.NlarxPanel.NlarxModel;

%set(this.Listeners,'Enabled','off'); %this does not help because of
%asynchronous behavior

% include linear model checkbox update
% use setSelected rather than doClick because no events should be fired.
linval = m.Nonlinearity(Ind).LinearTerm;
if strcmpi(linval,'on')
    javaMethodEDT('setSelected',this.NlarxPanel.jIncludeLinearModelCheckBox,true);
else
    javaMethodEDT('setSelected',this.NlarxPanel.jIncludeLinearModelCheckBox,false);
end

nl =  m.Nonlinearity(Ind); %current nonlinearity
%nl = initreset(nl); 
%thisNLstr = char(this.jMainPanel.getCurrentNonlinID);

numu = nl.NumberOfUnits;
%disp('wavenetoptions:refreshPanelWidgets')
if ischar(numu)
    if strcmpi(numu,'auto')
        javaMethodEDT('setSelected',this.jAutoRadio,true);
    else
        %interactive
        javaMethodEDT('setSelected',this.jChooseInteractivelyRadio,true);
    end
    if this.jNumUnitsEdit.isEnabled
        javaMethodEDT('setEnabled',this.jNumUnitsEdit,false);
    end
    
else
    %numeric
    % switch off listener
    %L = find(this.Listeners,'SourceObject',handle(this.jUserDefinedRadio,'callbackproperties'));      
    this.jMainPanel.setNumUnits(java.lang.String(int2str(numu))); % event thread method
    javaMethodEDT('setSelected',this.jUserDefinedRadio,true); 
    if ~this.jNumUnitsEdit.isEnabled
        javaMethodEDT('setEnabled',this.jNumUnitsEdit,true);
    end
end
 
% update the underlying Object property:
this.Object = nl;
%set(this.Listeners,'Enabled','on');

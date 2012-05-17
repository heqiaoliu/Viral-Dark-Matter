function handleModelRemovedEvent(this,Type,modelname)
%Handle the event of a new idnlarx/idnlhw model being removed from the main
% GUI's model board.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 06:12:36 $

% If current model (model last estimated) is being removed, reset the
% LatestEstimModelName property in appropriate model panel
currname = this.getPanelForType(Type).LatestEstimModelName;
if strcmp(currname,modelname)
    nlgui = nlutilspack.getNLBBGUIInstance;
    nlgui.setLatestEstimModelName('',Type); % resets GUI widgets
    
    % last estimated model is no longer available; continuing iterations
    % therefore is not possible. Reset the model parameters to [] but
    % retain the configurations under Configure tab
    
    this.uninitializeCurrentModel;
end

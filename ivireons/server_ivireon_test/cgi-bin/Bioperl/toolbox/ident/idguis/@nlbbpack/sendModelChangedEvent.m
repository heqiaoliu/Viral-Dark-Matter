function sendModelChangedEvent(expectedType)
% send VisibleModelChanged event if conditions meet
% expectedType: 'idnlarx' or 'idnlhw'

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:12:26 $

%disp('event fired')

nlgui = nlutilspack.getNLBBGUIInstance;
Type = nlgui.ModelTypePanel.getCurrentModelTypeID;
if strcmp(Type,expectedType)
    nlgui.send('VisibleModelChanged');
end

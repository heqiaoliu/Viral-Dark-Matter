function updateModel(this,m)
%Replace the current value of this.NlarxModel with m.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:13 $

this.NlhwModel = []; 
this.NlhwModel = m;

%{
if ~isestimated(m)
    % m contained structural changes
    nlgui = nlutilspack.getNLBBGUIInstance;
    Type = nlgui.ModelTypePanel.getCurrentModelTypeID;
    if strcmp(Type,'idnlhw')
        nlgui.send('VisibleModelChanged');
    end
end
%}
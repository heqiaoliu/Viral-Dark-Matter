function updateModel(this,m)
%Replace the current value of this.NlarxModel with m.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:12:56 $

this.NlarxModel = []; 
this.NlarxModel = m;

%{
if ~isestimated(m)
    % m contained structural changes
    nlgui = nlutilspack.getNLBBGUIInstance;
    Type = nlgui.ModelTypePanel.getCurrentModelTypeID;
    if strcmp(Type,'idnlarx')
        nlgui.send('VisibleModelChanged');
    end
end
%}
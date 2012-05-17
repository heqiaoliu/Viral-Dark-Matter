function refreshInfoOnModel(this,Type,selInd)
%Refresh contents of info panel for selected model in combobox

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:36 $

%this.refreshInfoOnModel(Type,selInd);
NewModelName = this.Data.(Type).ExistingModels{selInd};
Model = LocalGetSelectedModel(Type,NewModelName);

% update selected index in object's records
this.Data.(Type).SelectionIndex = selInd;

% update info panel contents
Dlg = this.jDialog;
Dlg.clearInfoAreaContents; % event thread method

info = guiDisplay(Model,NewModelName); %cell array of strings
this.jInfoArea.append(info); % event thread method

%--------------------------------------------------------------------------
function Model = LocalGetSelectedModel(Type,newModelName)
% return selected model

allmodels = nlutilspack.getAllCompatibleModels(Type,false,false);
Model = [];
for k = 1:length(allmodels)
    if strcmp(allmodels{k}.Name,newModelName)
        Model = allmodels{k};
        break;
    end
end
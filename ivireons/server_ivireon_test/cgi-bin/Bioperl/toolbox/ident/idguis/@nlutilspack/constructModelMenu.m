function constructModelMenu(this)
%Construct the model menu for the idnlarx plot figure of ident GUI.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:20 $

currmodname = this.CurrentModelHandle.ModelName;
ui = findall(this.Figure,'type','uimenu','Label','&Model');
delete(allchild(ui));
modelcallback = @(es,ed)localModelSelectedCallback(es,this,ui);
for k = 1:length(this.ModelHandles)
    thisModelH = this.ModelHandles(k);
    if thisModelH.isActive
        u = uimenu(ui,'Label',thisModelH.ModelName,'Callback',modelcallback);
        if strcmp(thisModelH.ModelName,currmodname)
            set(u,'Checked','on');
        end
    end
end


%--------------------------------------------------------------------------
function localModelSelectedCallback(es,this,ui)

if strcmpi(get(es,'checked'),'on')
    return
end

set(get(ui,'Children'),'checked','off');
set(es,'checked','on')

selectedModel = find(this.ModelHandles,'ModelName',get(es,'Label'));

this.CurrentModelHandle = selectedModel;
%this.refreshOutputCombo;
this.showPlot;

function addModel(this,mobj)
% add a new model (nlarxdata object) to the plot object

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:50:56 $

if ~this.isGUI
    % adding models capability is for GUI only
    return;
end

name = mobj.ModelName;

% check if model already exists
obj = find(this.ModelData,'ModelName',name); %#ok<EFIND>

if ~isempty(obj)
    % this should not happen
    ctrlMsgUtils.warning('Ident:idguis:invalidState',name);
    return;
end

% update list of model data objects 
this.ModelData = [this.ModelData;mobj];

% update outputcombo
%this.updateCombos; % there is only one combo to update

% update regressor related info
this.addRegData(mobj);

% refresh output names
this.OutputNames = this.getOutputNames;

% refresh list of active regressors that actually show in the combo boxes
this.updateActiveRegressors;

localAddModel(this,mobj);
%this.generateRegPlot(false); %isNew=false

this.updateLabelLegendCombo;
%this.showPlot;

%--------------------------------------------------------------------------
function localAddModel(this,h)
% add model's response to all existing panels 

model = h.Model;
ynames = model.yname;

for k = 1:length(ynames)
    thisy = ynames{k};
    pk = findobj(this.MainPanels,'type','uipanel','tag',thisy);
    
    if isempty(pk)
        % a panel for this output does not exist (do nothing)
        continue;
    end
    
    robj = find(this.RegressorData,'OutputName',thisy);
    ax = findobj(pk,'type','axes','tag',thisy);
    hold(ax,'on');
    this.utPlot(ax,h,robj); %add lines for output thisy of h.Model   
end


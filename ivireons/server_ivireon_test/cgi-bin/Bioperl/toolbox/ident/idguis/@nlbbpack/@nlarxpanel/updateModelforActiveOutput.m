function updateModelforActiveOutput(this)
% When user changes output selection or hits estimate button, the
% nonlinearity info for Active (previous) output must be saved into the
% model.

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/07/09 20:52:17 $

Ind = this.ActiveOutputIndex;

% Regressor options
% the regressors are always current; no action required

% Nonlinearity options
thisNL = char(this.jMainPanel.getCurrentNonlinID);

nl = this.NonlinOptionsPanels.(thisNL).Object;
m = this.NlarxModel;

% Reset old NL parameter values, which might have been set by selecting an
% initial model.
resetReg = false;
if ~strcmp(class(m.nl(Ind)),class(nl))
    oldNLStr = LocalGetnlType(class(m.nl(Ind)));
    oldnl = this.NonlinOptionsPanels.(oldNLStr).Object;
    this.NonlinOptionsPanels.(oldNLStr).Object = initreset(oldnl);
    
    % If nonlinearity was changed from linear to something else, reset
    % model's nonlinear regressors to 'all'. 
    if strcmp(class(m.nl(Ind)),'linear')
        resetReg = true;
    end     
end

nochange = true;

if this.applyToAllOutputs
    try
        for k = 1:size(m,'ny')
            if ~isequalwithequalnans(m.Nonlinearity(k),nl)
                nochange = false;
                m.Nonlinearity(k) = nl;
            end
        end
    catch
        nl = initreset(nl);
        this.NonlinOptionsPanels.(thisNL).Object = nl;
        for k = 1:size(m,'ny')
            m.Nonlinearity(k) = nl;
        end
    end
elseif this.isSingleOutput
    try
        if ~isequalwithequalnans(m.Nonlinearity,nl)
            nochange = false;
            m.Nonlinearity = nl;
        end
    catch
        nl = initreset(nl);
        this.NonlinOptionsPanels.(thisNL).Object = nl;
        m.Nonlinearity = nl;
    end
else
    try
        if ~isequalwithequalnans(m.Nonlinearity(Ind),nl)
            nochange = false;
            m.Nonlinearity(Ind) = nl;
        end
    catch
        nl = initreset(nl);
        this.NonlinOptionsPanels.(thisNL).Object = nl;
        m.Nonlinearity(Ind) = nl;
    end
end

if resetReg
    nochange = false;
    if this.isSingleOutput
        m.NonlinearRegressors = 'all';
    else
        m.NonlinearRegressors{Ind} = 'all';
    end
end

if ~nochange
    this.updateModel(m);
end

this.ActiveOutputIndex = this.getCurrentOutputIndex;
this.RegEditDialog.ActiveOutputIndex = this.ActiveOutputIndex;

if this.RegEditDialog.jMainPanel.isVisible
    this.RegEditDialog.updateDialogContents;
end

%--------------------------------------------------------------------------
function str = LocalGetnlType(nl)

str = nl;
switch nl
    case 'treepartition'
        str = 'tree';
    case 'sigmoidnet'
        str = 'sigmoid';
    case 'customnet'
        str = 'custom';
end

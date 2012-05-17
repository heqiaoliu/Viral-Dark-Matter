function attachListeners(this,varargin)
% Attach listeners to estimation panel widgets

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/10/31 06:12:29 $

h1 = handle(this.jEstimationOptionsButton,'CallbackProperties');
L1 = handle.listener(h1,'ActionPerformed', @(es,ed)LocalShowEstimOptions(this));

L2 = handle.listener(this.OptimMessenger,'optiminfo',@(es,ed)LocalOptimInfoReceived(es,ed,this));

h = handle(this.jReiterateCheckBox,'CallbackProperties');
% attach action performed rather than state changed to avoid firing
% callback when selection is made programmatically by calling setSelected.
L3 = handle.listener(h,'ActionPerformed', @(x,y)LocalReiterateOption(y));

this.Listeners = [L1, L2, L3];

end %function

%--------------------------------------------------------------------------
function LocalShowEstimOptions(this)

import com.mathworks.toolbox.ident.nnbbgui.*;

% update the object in the property inspector
p = NonlinPropInspector.getInstance;
optionsobj = this.getAlgorithmOptions;
%this.hideFocusIfNlhw;
p.getPropertyViewPanel.setObject(optionsobj);

% show the property inspector
p.showInspector('algorithm','x');

end % function
%--------------------------------------------------------------------------
function LocalOptimInfoReceived(es, ed,this)

if ~es.Enabled || any(strcmpi(ed.Info.ModelType,{'idss','idpoly','idgrey','idproc','idarx'}))
    return;
end

info = LocalNum2Str(ed.Info);
tablemodel = this.jTableModel;
jTable = this.jTable;
tabledata =  cell(tablemodel.getData);

switch ed.propertyName
    case 'optimStartInfo'
        % replace disabled estimate button with enabled STOP button
        nlgui = nlutilspack.getNLBBGUIInstance;
        nlgui.jGuiFrame.getMainPanel.setBusy(1);

        if length(this.IterTableIndices)==1
            % initialize tabledata
            tabledata = {'Initializing model parameters...','','','',''};
            if ~strcmpi(ed.Info.Name,'lsqnonlin')
                tabledata(2,:) = info;
            end
        else
            tabledata(end+1,:) = {'Output Error Minimization...','','','',''};
            if ~strcmpi(ed.Info.Name,'lsqnonlin')
                tabledata(end+1,:) = info;
            end
        end
        LocalUpdateTable;
    case 'optimIterInfo'
        alg = this.getAlgorithmOptions;
        if ed.Info.Iteration<=alg.Maximum_Iterations %lsqnonlin issue
            tabledata = [tabledata;info];
            LocalUpdateTable;
        end
    case 'optimEndInfo'
        %tabledata = [tabledata;info];
        %LocalUpdateTable
        this.IterTableIndices = [1 size(tabledata,1)+1];
end
%-------------- inner function to LocalOptimInfoReceived ---------
    function LocalUpdateTable

        tabledata = nlutilspack.matlab2java(tabledata);
        tablemodel.setData(tabledata, this.IterTableIndices-1, size(tabledata,1), size(tabledata,1) );
        R = this.jTable.getBounds;
        javaMethodEDT('revalidate',jTable);
        javaMethodEDT('scrollRectToVisible',this.jTable,java.awt.Rectangle(R.x,R.height,R.width,R.height));
    end

end % end function LocalOptimInfoReceived

%--------------------------------------------------------------------------
function x = LocalNum2Str(info)

x = cell(1,5);
x{1} = int2str(info.Iteration);
x{2} = sprintf('%5.4g',info.Cost);
x{3} = sprintf('%5.4g',info.StepSize);
x{4} = sprintf('%5.4g',info.Optimality);
x{5} = int2str(info.Bisections);

end

%--------------------------------------------------------------------------
function LocalReiterateOption(ed)
% callback for "use current model as initial guess" checkbox under
% reiteration options
%disp('EstimationPanel:LocalReiterateOption')
nlgui = nlutilspack.getNLBBGUIInstance;
if ~ed.Source.isSelected %(ed.JavaEvent.getStateChange==java.awt.event.ItemEvent.DESELECTED)
    % if unchecked, model parameters become uninitialized
    nlgui.ModelTypePanel.uninitializeCurrentModel;
else
    %this.ModelTypePanel.Data.idnlarx.ExistingModels
    Type = nlgui.ModelTypePanel.getCurrentModelTypeID;
    currname = nlgui.ModelTypePanel.getCurrentModelPanel.LatestEstimModelName;
    nlgui.ModelTypePanel.updateForNewInitialModel(Type,currname,false)
end

end %function


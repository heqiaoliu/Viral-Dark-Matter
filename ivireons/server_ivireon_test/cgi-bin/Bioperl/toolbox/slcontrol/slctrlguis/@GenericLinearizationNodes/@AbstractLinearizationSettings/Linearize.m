function [resultnode, varargout] = Linearize(this,io,ops,opt)
% LINEARIZE  Linearize a model or block given a set of options
%
 
% Author(s): John W. Glass 06-May-2008
%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:41:16 $

% Get the state order specified in the options dialog
OpTask = getOpCondNode(this);

if OpTask.EnableStateOrdering
    % Get the state order specified in the options dialog
    OpTask = getOpCondNode(this);
    var_inputs = {'StateOrder',OpTask.StateOrderList};
else
    var_inputs = {};
end

% Check the flag to store the Jacobian data.
var_inputs = [var_inputs,'StoreJacobianData',strcmp(OpTask.StoreDiagnosticsInspectorInfo,'on')];

% Linearize the model
if all(isa(ops,'double'))
    if isempty(io)
        [sys,op_ss,InspectorData,iostruct] = linearize(this.Model,ops,opt,var_inputs{:});
    else
        [sys,op_ss,InspectorData,iostruct] = linearize(this.Model,ops,io,opt,var_inputs{:});
    end
    if nargout == 2
        varargout{1} = op_ss;
    end
else
    if strcmp(OpTask.Options.LinearizationAlgorithm,'blockbyblock')
        if isempty(io)
            [sys,InspectorData,iostruct] = linearize(OpTask.Model,ops,OpTask.Options,var_inputs{:});
        else
            [sys,InspectorData,iostruct] = linearize(OpTask.Model,ops,io,OpTask.Options,var_inputs{:});
        end
    else
        [sys,InspectorData,iostruct] = linearize(OpTask.Model,ops,OpTask.Options,var_inputs{:});
    end
end

% Compute the number of linearizations at different operating points
nlinearizations = size(sys,3);

% Create a new analysis node
resultnode = GenericLinearizationNodes.LinearAnalysisResultNode('Model');
resultnode.Label = resultnode.createDefaultName(sprintf('Model'), this);
resultnode.Model = this.Model;

% Store the options that were used
resultnode.LinearizationOptions = copy(opt);

% Set the name of the lti object array
set(sys,'Name',sprintf('%s',resultnode.Label));

% Add the data the linearization results node
resultnode.LinearizedModel = sys;
if ~isempty(InspectorData) && strcmp(OpTask.Options.LinearizationAlgorithm,'blockbyblock')
    resultnode.ModelJacobian = [InspectorData.J];
    resultnode.InspectorNode = InspectorData.TopTreeNode;
    resultnode.BlocksInPathByName = InspectorData.BlocksInPathByName;
    resultnode.DiagnosticMessages = InspectorData.DiagnosticMessages;
end
resultnode.Description = sprintf('%d - Linear Model(s)',nlinearizations);
resultnode.IOStructure = iostruct;

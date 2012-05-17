function resultnode = operpoint_linearize(this,io,op_nodes,opt)
% OPERPOINT_LINEARIZE  Linearize the model using operating points
%
 
% Author(s): John W. Glass 16-Aug-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/05/31 23:29:18 $


% Get the operating points
for ct = 1:numel(op_nodes);
    ops(ct) = getOperPoint(op_nodes(ct));
end

% Linearize the model
resultnode = Linearize(this,io,ops,opt);

% Add the operating point nodes to the result node
nlinearizations = numel(op_nodes);
SysNotes = cell(nlinearizations,1);
for ct = 1:nlinearizations
    resultnode.addNode(op_nodes(ct));
    SysNotes{ct} = op_nodes(ct).Label;
end

% Store the notes in the linearized model
sys = resultnode.LinearizedModel;
set(sys,'Notes',SysNotes);
resultnode.LinearizedModel = sys;
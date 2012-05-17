function node = getOpCondNode(this)
%Get the operating condition generation node

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/12/04 23:27:01 $

%% Get the project node
project = this.up;

%% Get the children
Children = project.getChildren;

%% Loop over children the get the operating conditions
for ct = 1:length(Children)
    node = Children(ct);
    if isa(node,'OperatingConditions.OperatingConditionTask')
        break
    end
end

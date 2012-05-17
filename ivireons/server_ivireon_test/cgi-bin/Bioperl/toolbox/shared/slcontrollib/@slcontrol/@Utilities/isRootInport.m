function bool = isRootInport(this,block)
% ISROOTINPORT Return true if BLOCK is a root-level inport block of its model.
%
% BLOCK is a Simulink block name or handle.

% Author(s): Erman Korkut
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2008/10/31 06:58:37 $

% Get block handle
h = getBlockHandle(this,block);
if ~isa(h,'Simulink.Inport')
    bool = false;
    return
else
% Get model name
    model = get(getModelHandleFromBlock(this,h),'Name');
    % Find the parent of the inport
    pr = get(h,'Parent');
    if strcmp(pr,model)
        bool = true;
    else
        bool = false;
    end
end


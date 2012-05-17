function slSelectBlock(blk)
%SLSELECTLOCK Selects only the passed Simulink block
%   SLSELECTBLOCK(blk) deselects all blocks in a Simulink system
%		and selects only the passed block
%
%   Copyright 2010 The MathWorks, Inc.

parent = get_param(blk, 'Parent');
selected = find_system(parent, 'SearchDepth', 1, 'findall', 'on', 'Selected', 'on');
for i = 1 : length(selected)
    set_param(selected(i), 'Selected', 'off');
end
set_param(blk, 'Selected', 'on');

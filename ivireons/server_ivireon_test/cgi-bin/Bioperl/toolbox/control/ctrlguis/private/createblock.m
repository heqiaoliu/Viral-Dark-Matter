function Block = createblock(Identifier, Position, bwidth, bheight, PatchColor, AxisHandle)
% ------------------------------------------------------------------------%
% Function: createBlock
% Purpose: Creats Block Structure for Block element in digram
% Arguments:
%     Identifier: Identifier of block (Identifier used in sisotool)
%       Position: Position of center of block
%         bwidth: Block width
%        bheight: Block height
%     PatchColor: Color of block
%     AxisHandle: Parent Axis
%
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.10.1 $ $Date: 2005/11/15 00:54:35 $


x = Position(1);
y = Position(2);

xoffset = bwidth/2;
xcoord = [x-xoffset, x-xoffset, x+xoffset, x+xoffset, x-xoffset];
yoffset = bheight/2;
ycoord = [y-yoffset, y+yoffset, y+yoffset, y-yoffset, y-yoffset];

PHandle = patch(xcoord, ycoord, PatchColor, 'Parent', AxisHandle);
THandle = text(x,y,.1, Identifier,   'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'HitTest', 'off', 'Parent', AxisHandle);
%'FontUnits', 'Normalized', 'FontSize', yoffset*1.3,

Block = struct( ...
    'Identifier', Identifier, ...
    'Position', Position, ...
    'Width', bwidth, ...
    'Height', bheight, ...
    'PatchColor', PatchColor, ...
    'PHandle', PHandle, ...
    'THandle', THandle, ...
    'Label', []);   
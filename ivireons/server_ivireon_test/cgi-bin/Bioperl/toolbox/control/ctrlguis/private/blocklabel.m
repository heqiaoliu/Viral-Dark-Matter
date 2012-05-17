function Block = blocklabel(Block, Location, ConfigData, AxisHandle, EditFlag)
% ------------------------------------------------------------------------%
% Function: blocklabel
% Purpose: Label box for Blocks
% Arguments:
%          Block: Structure created by createblock
%       Location: Location of label {T,L,B,R}
%     ConfigData: @design object
%     AxisHandle: Parent Axis
%       EditFlag: boolean if label is editable
%
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.10.2 $ $Date: 2008/12/29 01:47:22 $

offset = .025; % label distance from block

% locaton of label
switch Location
    case 'T'
        Position = getpos(Block,'T') + [0,offset];
        HA = 'Center';
        VA = 'BaseLine';
    case 'L'
        Position = getpos(Block,'L') + [-offset, 0];
        HA = 'Right';
        VA = 'Middle';
    case 'B'
        Position = getpos(Block,'B') + [0, -offset];
         HA = 'Center';
         VA = 'Cap';
    case 'R'
        Position = getpos(Block,'R') + [offset, 0];
        HA = 'Left';
        VA = 'Middle';
end


Block.Label = handle(text('Parent', AxisHandle, ...%'BackgroundColor', [1,1,1], ...
    'HorizontalAlignment', HA, ...
    'VerticalAlignment', VA, ...
    'FontUnits', 'Normalized',...%'FontSize', 0.04, ...
    'String', ConfigData.(Block.Identifier).Name, ...
    'Position', Position));

if EditFlag
    set(Block.Label,'buttondown','set(gco,''Editing'',''on'')');

    set(Block.Label,'userdata', addlistener(Block.Label, 'String',...
        'PostSet', @(es,ed) LocalUpdateBlockName(es,ed, Block.Identifier, ConfigData)));
    
    
end

        

% ------------------------------------------------------------------------%
% Function: LocalUpdateBlockName
% Purpose: Update Block Name
% ------------------------------------------------------------------------%
function LocalUpdateBlockName(hsrc, eventdata, Identifier, ConfigData)

NewName = get(eventdata, 'NewValue');
if isempty(NewName) || all(' ' == NewName)
    set(eventdata.AffectedObject,'string', ConfigData.(Identifier).Name)
else
    ConfigData.(Identifier).Name = get(eventdata, 'NewValue');
end
        

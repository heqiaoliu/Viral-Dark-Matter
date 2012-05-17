function Signal = signallabel(Anchor, Location, SigType, idx, ConfigData, AxisHandle,EditFlag)
% ------------------------------------------------------------------------%
% Function: signallabel
% Purpose: Label box for Signals
% Arguments:
%         Anchor: Which clock or sum it is attached to
%       Location: Location of label {T,L,B,R}
%        SigType: Input or Output
%            idx: Index of @design data for input and output signal names
%     ConfigData: @design object
%     AxisHandle: Parent Axis
%       EditFlag: Boolean if label is editable
% ------------------------------------------------------------------------%

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.10.2 $ $Date: 2008/12/29 01:47:23 $


offset = 0.03;

switch Location
    case 'T'
        Position = Anchor + [0, offset];
        HA = 'Center';
        VA = 'BaseLine';
    case 'L'
        Position = Anchor + [-offset, 0];
        HA = 'Right';
        VA = 'Middle';
    case 'B'
        Position = Anchor + [0, -offset];
        HA = 'Center';
        VA = 'Cap';
    case 'R'
        Position = Anchor + [offset, 0];
        HA = 'Left';
        VA = 'Middle';
end

Signal.Label = handle(text('Parent', AxisHandle, ...
            'HorizontalAlignment', HA, ...
            'VerticalAlignment', VA, ...
            'FontUnits', 'Normalized',...
            'String', ConfigData.(SigType){idx}, ...
            'Position', Position));
   
if EditFlag     
    set(Signal.Label,'buttondown','set(gco,''Editing'',''on'')');
    %set(Signal.Label,'buttondown',{@LocalBtnDownFcn});    

    set(Signal.Label,'userdata', addlistener(Signal.Label, 'String',...
        'PostSet', @(es,ed) LocalUpdateSignalName(es,ed, SigType, idx, ConfigData))); 
end


% ------------------------------------------------------------------------%
% Function: LocalBtnDownFcn
% Purpose: Button Down Function
% ------------------------------------------------------------------------%
% function LocalBtnDownFcn(hsrc, eventdata)
% get(hsrc,'visible')
% isVis = strcmpi(get(hsrc,'visible'),'on');
% if isVis 
%     set(hsrc,'Editing','on');
% end
        
        
            
% ------------------------------------------------------------------------%
% Function: LocalUpdateSignalName
% Purpose: Update Signal Name
% ------------------------------------------------------------------------%
function LocalUpdateSignalName(hsrc, eventdata, SigType, idx, ConfigData)

NewName = get(eventdata, 'NewValue');
if isempty(NewName) || all(' ' == NewName)
    set(eventdata.AffectedObject,'string', ConfigData.(SigType){idx});
else
    ConfigData.(SigType){idx} = get(eventdata, 'NewValue');
end

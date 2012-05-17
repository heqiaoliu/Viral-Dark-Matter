function revertit(varargin)
%REVERTIT Revert a DEE edit session.
%   REVERTIT is the callback for the syseditor's control panel
%   Revert button.  The syseditor's system is reverted to the
%   system as it was defined before the DEE panel was opened.
 
%   Copyright 1990-2008 The MathWorks, Inc.

% The function deeupdat always finishes by putting the previous systems
% specs into the UserData facility associated with each edit field

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First get handle to the control panel for the syseditor and then get the
%     handles for each edit field (these can be found in the UserData for 
%     the figure itself)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get handle to the syseditor's figure window
fig = varargin{1};

switch get(fig,'type')
    case 'uicontrol'
        fig = get(fig, 'parent');
    case 'figure',
    otherwise,
        error('Simulink:revertit:badInput',...
            'bad input to deeupdat...expected button or figure handle');
end
% set mouse pointer to watch
set(fig,'Pointer','Watch');
drawnow

% get handles for edit blocks and status field
controlhands = get(fig,'UserData');
se = controlhands(1);
so = controlhands(2);
ic = controlhands(3);
ni = controlhands(4);

% get values for edit strings from the edit blocks UserDatas
sestring = get(se,'UserData');     % state derivative equations
sostring = get(so,'UserData');     % system output equations
icstring = get(ic,'UserData');     % initial conditions 
nistring = get(ni,'UserData');     % number of inputs 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  update the edit fields in the control panel to reflect the new strings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(se,'String',sestring);
set(ic,'String',icstring);
set(so,'String',sostring);
set(ni,'String',nistring);

deeupdat(fig)

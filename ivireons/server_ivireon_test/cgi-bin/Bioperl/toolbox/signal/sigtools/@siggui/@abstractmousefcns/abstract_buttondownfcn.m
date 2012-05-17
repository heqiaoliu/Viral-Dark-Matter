function abstract_buttondownfcn(this, hcbo)
%AXESTOOL_BUTTONDOWNFCN ButtonDown function for the abstractmousefcns

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2008/08/22 20:33:05 $

% This should be a private method

% If the button is already down do nothing
if strcmpi(get(this,'ButtonState'), 'down'),
    set(this, 'ButtonState', 'DoubleDown');
    return; 
end

% Set up the figure to act as an "abstract"
hax  = ancestor(hcbo, 'axes');
hfig = ancestor(hax, 'figure');

% Save the previous window button functions
set(this, 'WindowButtonMotionFcn', get(hfig, 'WindowButtonMotionFcn'), ...
    'WindowButtonUpFcn', get(hfig, 'WindowButtonUpFcn'));

% Set the window button functions to use abstract
set(hfig, ...
    'WindowButtonMotionFcn', @(hfig, ev) abstract_mousemotionfcn(this), ...
    'WindowButtonUpFcn', @(hfig, ev) abstract_buttonupfcn(this));

set(this, 'CallbackObject', hcbo, ...
    'CurrentAxes', hax, ...
    'ButtonClickType', getClickType(get(hax, 'Parent')), ...
    'CurrentPoint', getCurrentPoint(hax), ...
    'ButtonState', 'Down');

buttondownfcn(this);

send(this, 'ButtonDown', handle.EventData(this, 'ButtonDown'));

% ---------------------------------------------------------
%       Utility Functions
% ---------------------------------------------------------

% ---------------------------------------------------------
function cp = getCurrentPoint(hax)

cp = get(hax, 'CurrentPoint');
cp = cp(1,1:2);


% ---------------------------------------------------------
function type = getClickType(hfig)

switch lower(get(hfig, 'SelectionType'))
case 'normal'
    type = 'Left';
case 'alt'
    type = 'Right';
case 'open'
    type = 'Double';
case 'extend'
    type = 'Shift';
end

% [EOF]

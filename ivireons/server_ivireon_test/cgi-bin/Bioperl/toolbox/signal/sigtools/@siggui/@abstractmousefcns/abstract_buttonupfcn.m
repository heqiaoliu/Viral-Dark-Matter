function abstract_buttonupfcn(h)
%AXESTOOL_BUTTONUPFCN Button up function for the abstract

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:10:25 $

% This should be a private method

% if strcmpi(h.ButtonState, 'DoubleDown'),
%     set(h, 'ButtonState', 'Down');
%     return;
% end

% Restore the original window button functions
hfig = get(get(h, 'CurrentAxes'), 'Parent');
set(hfig, ...
    'WindowButtonMotionFcn', get(h, 'WindowButtonMotionFcn'), ...
    'WindowButtonUpFcn', get(h, 'WindowButtonUpFcn'));

set(h, 'WindowButtonMotionFcn', [], ...
    'WindowButtonUpFcn', []);

buttonupfcn(h);

set(h, 'ButtonState', 'Up');

send(h, 'ButtonUp', handle.EventData(h, 'ButtonUp'));

% Set this last so that BUTTONDOWNFCN and listeners have access to the axes.
% set(h, 'CurrentAxes', -1);

% [EOF]

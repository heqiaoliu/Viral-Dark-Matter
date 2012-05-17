function abstract_mousemotionfcn(h)
%AXESTOOL_MOUSEMOTIONFCN MouseMotion function for the abstract

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:10:26 $

% This should be a private method

hax = get(h, 'CurrentAxes');

% Capture the current point of the axes
cp = get(hax, 'CurrentPoint');
set(h, 'CurrentPoint', [cp(1) cp(3)]);
mousemotionfcn(h);

send(h, 'MouseMotion', handle.EventData(h, 'MouseMotion')); 

% [EOF]

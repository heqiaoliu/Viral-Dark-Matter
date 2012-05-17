function parameters_listener(hPD, eventData)
%PARAMETERS_LISTENER Listener to the parameters Property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:12:44 $

% This is a when rendered listener

% Update the size of the figure
fix_figure(hPD);

% Delete the old handles.  This will leave the dialog buttons because they
% are stored in DialogHandles
delete(handles2vector(hPD));

% Render the controls for the new parameters.
render_controls(hPD);

set(hPD, 'DisabledParameters', {''});

% -------------------------------------------------------
function fix_figure(hPD)

hFig = get(hPD, 'FigureHandle');
sz = parameter_gui_sizes(hPD);

pos = get(hFig, 'Position');
pos(3:4) = sz.fig(3:4);
set(hFig, 'Position', pos);


% [EOF]

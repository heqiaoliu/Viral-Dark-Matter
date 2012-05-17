function setanimation(h)
%SETANIMATION  Set animation mode for multipath figure object.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 01:58:16 $

animationMode = get(h.UIHandles.AnimationMenu, 'value');
switch animationMode
    case 1
        N = 0;
    case 2
        N = 0;
    case 3
        N = 0.25;
    case 4
        N = 0.5;
end

% Set maximum number of snapshots for all axes.
axObjs = h.AxesObjects;
for m = 1:h.NumAxes
    ax = axObjs{m};
    if ( ~isequal(class(ax), 'channel.mpdoppleraxes') ...
            && ~isequal(class(ax), 'channel.mpscatteraxes') )     
        ax.MaxNumSnapshots = round(10.^(log10(ax.BufferLength)*(1-N)));
    end
end

% Initialize slider step.
buffSize = h.CurrentChannel.PGAndTGBufferSizes;
hSlider = h.UIHandles.Slider;
numPos = round(10.^(log10(buffSize)*(1-N)));
steps = [1/(numPos-1) 0.1];
if steps(1) > steps(2)
    steps(2) = steps(1);
end
set(hSlider, 'sliderstep', steps);

% Update multipath axes schedule.
h.updateschedule;

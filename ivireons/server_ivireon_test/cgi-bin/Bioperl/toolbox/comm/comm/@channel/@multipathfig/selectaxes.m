function selectaxes(h, menuObj)
%SELECTAXES  Select current axes for multipath figure object.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/05/14 15:01:25 $

% Return if not completed previous selectaxes callback.
if h.CurrentlySelectingAxes
    return;
end

% Set flag to avoid selectaxes callback clashes.
h.CurrentlySelectingAxes = true;

% Get current menu index.
ui = h.UIHandles;
visMenu = ui.VisMenu;
menuIdx = get(visMenu, 'value');

% Set axes positions.
h.setaxespositions;

% Update axes schedule.
h.updateschedule;

% If any of the axes is not a Doppler spectrum, make the slider visible.
modeslider = 'off';
% If the axes is a Doppler spectrum, make the path number edit box visible
modepathnum = 'off';

axObjs = h.AxesObjects;
selectedAxesIdx = h.AxesIdxDirectory{menuIdx};
for n = 1:length(selectedAxesIdx)

    % Get multipath axes object.
    m = selectedAxesIdx(n);
    ax = axObjs{m};

    if ( ~isequal(class(ax), 'channel.mpdoppleraxes') ...
            && ~isequal(class(ax), 'channel.mpscatteraxes') )
        modeslider = 'on';
    else
        % Release pause button if Doppler spectrum selected.
        pbObj = ui.PauseButton;
        if get(pbObj, 'value')==1
            set(pbObj, 'value', 0);
            pausebutton(h, pbObj);
        end
    end
    
    if isequal(class(ax), 'channel.mpdoppleraxes')
        modepathnum = 'on';
    end    
    
end
set([ui.AnimationMenu, ui.AnimationMenuText, ...
     ui.Slider, ui.SampleIdx, ui.SliderText, ui.PauseButton], ...
    'visible', modeslider);
set([ui.PathNumberText,ui.PathNumber], 'visible', modepathnum);

% Refresh snapshot if necessary.
h.refreshsnapshot;

% Allow processing of new selectaxes callbacks.
h.CurrentlySelectingAxes = false;

% Call selectaxes if menu selection has changed.
if (menuIdx ~= get(visMenu, 'value'))
    selectaxes(h, visMenu);
end

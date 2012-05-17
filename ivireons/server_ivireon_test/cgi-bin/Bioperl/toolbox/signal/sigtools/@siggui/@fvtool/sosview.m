function sosview(this)
%SOSVIEW   Change the way we view SOS filters

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/05 18:00:49 $

hdlg = getcomponent(this, '-class', 'siggui.sosviewdlg');

% If the dialog has not been instantiate yet, create on.
if isempty(hdlg),
    hdlg = siggui.sosviewdlg;
    addcomponent(this, hdlg);

    % Sync up the options stored in FVTool with the new dialog.
    opts_listener(this);

    % Add listeners to keep the dialog and fvtool in sync.
    l = [ ...
        handle.listener(hdlg, 'DialogApplied', @lcldialogapplied_listener); ...
        handle.listener(this, this.findprop('sosviewopts'), 'PropertyPostSet', ...
            @opts_listener); ...
        ];
    set(l, 'CallbackTarget', this);
    set(this, 'SosViewListeners', l);
end

% If the dialog is not rendered, render it and center it on FVTool.
if ~isrendered(hdlg),
    render(hdlg);
    centerdlgonfig(hdlg, this);
end

set(hdlg, 'Visible', 'on');
figure(hdlg.FigureHandle);

% -------------------------------------------------------------------------
function opts_listener(this, eventData)

hdlg = getcomponent(this, '-class', 'siggui.sosviewdlg');
opts = get(this, 'sosViewOpts');
if ~isempty(opts)
    setopts(hdlg, opts);
end

% -------------------------------------------------------------------------
function lcldialogapplied_listener(this, eventData)

% If the current filter is not a single SOS filter warn that we will be
% ignoring the settings.
Hd = get(this, 'Filters');

% Check if we will actually use the settings for the current filter.
if length(Hd) ~= 1
    warnstate = true;
elseif ~isa(Hd.Filter, 'dfilt.abstractsos')
    warnstate = true;
else
    warnstate = false;
end

% If we aren't going to use the settings put up a dontshowagaindlg.
if warnstate
    h = siggui.dontshowagaindlg;
    set(h, ...
        'Name', 'SOS View', ...
        'Text', {'The SOS View settings only apply when you have a single second-order section filter.  Your settings have been saved for later use.'}, ...
        'PrefTag', 'sosviewwarning');

    % The need2show method returns false if the user has checked the box in
    % the past.  If it returns true, render the dialog and make it visible.
    if h.need2show

        render(h);
        set(h, 'Visible','on');

        % Add a listener to the parent being deleted so that we can
        % destroy the dontshowagain dialog.
        addlistener(this.FigureHandle, 'ObjectBeingDestroyed', ...
            @(hh, eventStruct) delete(h));
    end
end

set(this, 'SosViewOpts', copy(getopts(eventData.Source, this.sosViewOpts)));

% [EOF]

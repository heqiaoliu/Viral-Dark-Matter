function panel = getPropsSchema(hCfg, hDlg) %#ok<INUSD>
%GetPropsSchema Construct dialog panel for SrcOptsext properties.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/04/27 19:55:45 $

% User-interface controls specific to sources

% Playback mode
if get(findProp(hCfg.PropertyDb, 'ShowPlaybackCmdMode'), 'Value')
    pbmode.Name           = 'Keyboard commands respect source playback modes';
    pbmode.Tag            = 'KeyboardCommands';
    pbmode.Type           = 'checkbox';
    pbmode.Source         = findProp(hCfg.PropertyDb, 'PlaybackCmdMode');
    pbmode.ObjectProperty = 'Value';
    pbmode.RowSpan        = [1 1];
    pbmode.ColSpan        = [1 2];
    
    items = {pbmode};
else
    items = {};
end

if get(findProp(hCfg.PropertyDb, 'ShowRecentSources'), 'Value')

    % Recently Used Sources
    %
    % Two parts to this control
    %  - Edit box containing list length
    rus1.Name            = 'Recently used sources list:';
    rus1.Type            = 'edit';
    rus1.Source          = findProp(hCfg.PropertyDb, 'RecentSourcesListLength');
    rus1.ObjectProperty  = 'Value';
    rus1.Tag             = 'RecentSourcesListLength';
    rus1.RowSpan         = [2 2];
    rus1.ColSpan         = [1 1];

    %  - static text placed just after edit box
    rus2.Name            = 'entries';
    rus2.Type            = 'text';
    rus2.RowSpan         = [2 2];
    rus2.ColSpan         = [2 2];
    
    items = {items{:}, rus1, rus2};
    
end

if isempty(items)
    panel = [];
    return;
end

% Define overall SrcOptsExt properties panel
%
panel.Type       = 'group';
panel.Name       = 'Source UI Options';
panel.Tag        = 'Overall';
panel.LayoutGrid = [3 2];
panel.RowStretch = [0 0 1];
panel.ColStretch = [0 1];
panel.Items = items;

% [EOF]

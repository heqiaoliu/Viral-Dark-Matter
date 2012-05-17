function render(this)
%RENDER   Render the eye diagram GUI window

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:23 $

% Get the standard size information
sz = baseGuiSizes(this);

% Set up the defaults for GUI sizes
origFontSize = get(0, 'defaultuicontrolfontsize');
set(0, 'defaultuicontrolfontsize', sz.fs');
if ~ispc
    origFontName = get(0, 'defaultuicontrolfontname');
    set(0, 'defaultuicontrolfontname', 'Helvetica');
end

% First make sure that there is a eyescope
hFig = this.FigureHandle;
if ishghandle(hFig) && strcmp(get(hFig, 'Tag'), 'EyeScope')

    if ~this.WindowRendered
        % There is no scope face, so render from scratch
        
        % Render
        handles = renderMenu(this);
        setappdata(hFig, 'MenuHandles', handles);

        render(this.CurrentScopeFace)

        this.WindowRendered = 1;

        % Render the title
        updateFigureTitle(this);
    end        
    
    % If it is outside the screen, bring it back in
    movegui(hFig, 'onscreen');

    % Make the figure visible
    set(hFig, 'Visible', 'on');
end

% Restore the defaults
set(0, 'defaultuicontrolfontsize', origFontSize);
if ~ispc
    set(0, 'defaultuicontrolfontname', origFontName);
end

%-------------------------------------------------------------------------------
% [EOF]

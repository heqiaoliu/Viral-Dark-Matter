function update(this)
%UPDATE	Update the eye diagram GUI window

%   @commscope/@eyediagramgui
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:24 $

% First make sure that there is an eyescope
hFig = this.FigureHandle;
if ishghandle(hFig) && strcmp(get(hFig, 'Tag'), 'EyeScope')
    if this.WindowRendered
        % There is a scope face, so we can update
        updateFigureTitle(this);
        update(this.CurrentScopeFace);
        updateMenu(this);
    end        
end

%-------------------------------------------------------------------------------
% [EOF]

function unrender(this)
%UNRENDER Unrender the eye diagram GUI main window.
%   UNRENDER(H) removes the menu, toolbar, scope face, and status bar.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:23:03 $

% If there is a scope face, unrender it
if this.WindowRendered
    hFig = get(this, 'FigureHandle');
    handles = getappdata(hFig, 'Handles');
    fnames = fieldnames(handles);

    for p=1:length(fnames)
        hField = handles.(fnames{p});
        delete(hField);
    end

    unrender(this.CurrentScope);
    
    this.WindowRendered = 0;
end
%-------------------------------------------------------------------------------
% [EOF]

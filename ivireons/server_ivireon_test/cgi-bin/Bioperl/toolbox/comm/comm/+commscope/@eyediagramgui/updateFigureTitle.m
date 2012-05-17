function updateFigureTitle(this)
%UPDATEFIGURETITLE Update the figure title

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/13 15:11:44 $

% Fisrt check if there is a scope face
if this.WindowRendered
    % If dirty, add a *
    if this.Dirty
        dirtyStr = ' *';
    else
        dirtyStr = '';
    end

    % If the path is current directory, do not include path
    sessionName = this.SessionName;
    [pathname filename ext] = fileparts(sessionName);
    currentDir = pwd;
    if strcmp(currentDir, pathname)
        sessionName = [filename ext];
    end

    % Create the string
    titleStr = ['EyeScope - [' sessionName dirtyStr ']'];

    % Set the figure title bar
    hFig = this.FigureHandle;
    set(hFig, 'Name', titleStr);
end
%-------------------------------------------------------------------------------
% [EOF]

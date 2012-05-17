function uiresume (hFigDlg)
%UIRESUME Resume execution of blocked MATLAB code.
%   UIRESUME(FIG) resumes the MATLAB code execution that was suspended by a
%   UIWAIT(FIG) command.  UIRESUME is a companion function to UIWAIT.
%
%   Example:
%       f = figure;
%       h = uicontrol('Position', [20 20 200 40], 'String', 'Continue', ...
%                     'Callback', 'uiresume(gcbf)');
%       disp('This will print immediately');
%       uiwait(gcf); 
%       disp('This will print after you click Continue'); close(f);
%
%   See also UIWAIT, WAITFOR.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.10.4.4 $  $Date: 2010/05/20 02:30:09 $

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('uiresume');

% -------- Validate argument
if nargin < 1,
    hFigDlg = gcf;
end
if ~strcmp (get(hFigDlg, 'Type'), 'figure') 
    error ('MATLAB:uiresume:InvalidInputType', 'Input argument must be of type dialog')
end

set (hFigDlg, 'waitstatus', 'inactive');

function uiwait(hFigDlg, timeOutVal)
%UIWAIT Block execution and wait for resume.
%   UIWAIT(FIG) blocks execution until either UIRESUME is called or the
%   figure FIG is destroyed (closed).  UIWAIT with no input arguments is
%   the same as UIWAIT(GCF).
%
%   UIWAIT(FIG, TIMEOUT), in addition to the previous syntax, blocks
%   execution until either TIMEOUT seconds elapse or one of the 
%   previous return conditions is met. TIMEOUT value cannot be less than
%   one second. In case the TIMEOUT value entered is less than one second 
%   that particular value will not be used and a TIMEOUT value of one
%   second will be used. 
%   
%   When the dialog or figure is created, it should have a 
%   uicontrol that either:
%       has a callback that calls UIRESUME, or
%       has a callback that destroys the dialog box
%   since these are the only methods that can resume program execution
%   after it has been suspended by the waitfor command.
%
%   UIWAIT is a convenient way to use the waitfor command and is used in
%   conjunction with a dialog box or figure.  When used with a modal
%   dialog (which captures all keyboard and mouse events), it provides a
%   way to suspend a MATLAB code and prevent the user from accessing any
%   MATLAB window until they respond to the dialog box.
%
%   Examples:
%       f = figure;
%       h = uicontrol('Position', [20 20 200 40], 'String', 'Continue', ...
%                     'Callback', 'uiresume(gcbf)');
%       disp('This will print immediately');
%       uiwait(gcf); 
%       disp('This will print after you click Continue'); close(f);
%
%   See also UIRESUME, WAITFOR.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.11.4.9 $  $Date: 2010/05/20 02:30:15 $

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('uiwait');

% -------- Validate argument

if nargin < 1,
    hFigDlg = gcf;
end

if ~isscalar(hFigDlg) || ~ishghandle(hFigDlg,'figure')
    error ('MATLAB:uiwait:InvalidInputType', 'Input argument must be of type figure')
end

% -------- Setup and start timer object if a second argument is passed
t = [];
if nargin == 2
    if ~isnumeric(timeOutVal)
        error('MATLAB:uiwait:InvalidSecondInput', 'Second input must be numeric');
    end
    if (timeOutVal < 1)
        timeOutVal = 1;
        warning('MATLAB:uiwait:InvalidSecondInput', 'Timeout value cannot be less than one second thus changing timeout value to one second.');
    end
    t = timer('TimerFcn',{@uiresumeWrapper,hFigDlg}); 
    % create a time vector, initialized to right now
    clockStart = clock;
    % increment the seconds column by timeOutVal
    clockStart(6) = clockStart(6) + timeOutVal;
    startat(t, clockStart);
end

% --------  Set the dialog's waitstatus property, and call waitfor
set (hFigDlg, 'visible', 'on', 'waitstatus', 'waiting');
waitfor (hFigDlg, 'waitstatus', 'inactive');

% --------  Clean up timer object if it's there
if ~isempty(t) && isobject(t)
    stop(t);
    delete(t); 
end


function uiresumeWrapper(t_handle, event, hFigDlg)
uiresume(hFigDlg)





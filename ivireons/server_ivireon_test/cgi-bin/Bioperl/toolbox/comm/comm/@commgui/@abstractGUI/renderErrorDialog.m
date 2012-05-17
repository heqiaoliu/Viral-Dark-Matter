function renderErrorDialog(this, exception, windowTitle) 
%RENDERERRORDIALOG Display an error message dialog box
%   RENDERERRORDIALOG(H, EXCEPTION, WINDOWTITLE) displays the error message of 
%   the MException EXCEPTION in an error dialog with title WINDOWTITLE.
%
%   RENDERERRORDIALOG(H, MSG, WINDOWTITLE) displays the error message MSG in 
%   an error dialog with title WINDOWTITLE.  MSG must be a string.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:59 $

if ischar(exception)
    % An error message is passed by the GUI.  Display the message.
    msg = exception;
else
    % An error was caught and the exception is passed by the GUI.  Display the
    % exception message.
    msg = cleanerrormsg(exception.message);
end

uiwait(errordlg(msg, windowTitle, 'modal'));
%-------------------------------------------------------------------------------
% [EOF]

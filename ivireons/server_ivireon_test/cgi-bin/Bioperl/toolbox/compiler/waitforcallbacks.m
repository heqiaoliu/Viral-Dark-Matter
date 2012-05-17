%WAITFORCALLBACKS Prevent deployed applications from exiting immediately after
%                 the main function returns.
%
%   After its main function returns, a deployed application will usually
%   terminate if there are no open figure windows.  Calling
%   WAITFORCALLBACKS(true) will prevent the application from exiting until
%   WAITFORCALLBACKS(false) is called.
%
%   It is an error to call WAITFORCALLBACKS(false) before calling
%   WAITFORCALLBACKS(true).
%
%   Calls to WAITFORCALLBACKS nest.  WAITFORCALLBACKS(false) must be called the
%   same number of times WAITFORCALLBACKS(true) has been called for a deployed
%   application to exit.
%
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/05 15:55:22 $

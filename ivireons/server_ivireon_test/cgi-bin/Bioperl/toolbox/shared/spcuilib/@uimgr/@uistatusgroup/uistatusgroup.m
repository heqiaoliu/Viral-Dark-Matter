function h = uistatusgroup(varargin)
%UISTATUSGROUP Constructor for uistatusgroup object.
%   UISTATUSGROUP object holds uistatus items to build up a status bar. A 
%   uistatusgroup is a named status option region, within a statusbar,
%   at the bottom of an HG figure window.
%
%   Unlike the standard uistatusbar, the uistatusgroup allows definition of
%   named groups of status options, and an order to those named groups.
%
%   UISTATUSGROUP(NAME,PLACE,S1,S2,...) sets the group name, the
%   status option group rendering placement, and adds uistatus objects
%   S1, S2, etc.  Specifying uistatus objects is optional.
%
%   UISTATUSGROUP(NAME,S1,S2,...) and UISTATUSGROUP(NAME) sets
%   placement to 0.
%

%
%    % Example:
%
%    h = uimgr.uistatusgroup(NAME,LABEL) 
%  
%    % This is used to create a uistatusgroup item within the UIMgr system.  
%    % It is most typical to use it as in this example: 
%  
%    % Create status options
%    ho2 = uimgr.uistatus('Rate', @status_opt_rate);
%    ho2.WidgetProperties = {'Tooltip', 'Frame rate'};
%    ho3 = uimgr.uistatus('Frame',@status_opt_frame);
% 
%    hStdOpts = uimgr.uistatusgroup('StdOpts',ho2, ho3); 
%  
%    where the first argument is the name to use for the new UIMgr node, 
%    and the second and third options are the status items contained in the
%    status group. 

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/06 20:47:23 $

% Allow subclass to invoke this directly
h = uimgr.uistatusgroup;

% This object does not support a user-specified widget function;
% the uistatusgroup simply confirms that a statusbar is present,
% and contains other uistatus/uistatusgroup objects.
h.allowWidgetFcnArg = false;

% Continue with standard group instantiation
h.uigroup(varargin{:});

% [EOF]

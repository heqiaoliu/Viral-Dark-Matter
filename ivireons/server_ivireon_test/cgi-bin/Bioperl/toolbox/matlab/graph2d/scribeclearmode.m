function scribeclearmode(fig,varargin)
%SCRIBECLEARMODE  Plot Editor helper function
%   Utility for cooperative mode switching.  Before taking over a
%   figure, call 
%       SCRIBECLEARMODE(Fig, OffCallbackFcn, Args, ...)
%
%   The OffCallbackFcn is stored with on the figure and is
%   executed with the arguments Args the next time OffCallbackFcn
%   is called.  In other words, SCRIBECLEARMODE notifies the
%   current mode that a new mode is taking over and also installs
%   its own notification function.

%   Copyright 1984-2005 The MathWorks, Inc. 
% $Revision: 1.8.4.1 $  $Date: 2005/09/12 18:59:16 $

% clear the current mode
s = getappdata(fig,'ScribeClearModeCallback');
if ~isempty(s) && iscell(s)
   func = s{1};
   if length(s)>1
      feval(func,s{2:end});
   else
      feval(func);
   end
end

% set notification callback for the new mode
if nargin>2
   s = varargin;
   setappdata(fig,'ScribeClearModeCallback',s);
else
   if isappdata(fig,'ScribeClearModeCallback')
      rmappdata(fig,'ScribeClearModeCallback');
   end
end

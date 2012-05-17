function newstate = pdeumtoggle(uimenu_handle)
%PDEUMTOGGLE Obsolete function.
%
%   See also UIMENU MENUBAR WINMENU

% Copied from matlab/uitools
%  Author: T. Krauss 10-14-94
%  Copyright 1984-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:50:38 $

str = get(uimenu_handle,'checked');
if strcmp(str,'on')
   newstate = 0;  newstr = 'off';
else
   newstate = 1;  newstr = 'on';
end
set(uimenu_handle,'checked',newstr)


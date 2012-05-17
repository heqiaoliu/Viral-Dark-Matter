function iduistat(string,flag,window,color)
%IDUISTAT Manages the status line in main ident window.
%   STRING: What to display on the status line
%   FLAG: If flag is =1, then the STRING is added to the current status
%   line, otherwise it replaces the old string.

%   L. Ljung 4-4-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2009/10/16 04:56:16 $

%global XIDstatus
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

if nargin<4, color = 'k'; end
if nargin<3 || isempty(window), window = 16; end
if nargin<2 || isempty(flag), flag = 0; end
if flag
    str1 = get(XID.status(window),'string');
    string = [str1,' ',string];
end
try
    set(XID.status(window),'string',string,'ForegroundColor',color)
end
drawnow

function idoptcmp%(arg,hm,replot)
%IDOPTTOG Toggles checked frequency options for the compare menu.

%   L. Ljung 9-27-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2006/06/20 20:08:25 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
pw=gcf;
if nargin<3,replot=1;end
if nargin<2
    hm=gcbo;%get(pw,'currentmenu');
end
usd=get(hm,'userdata');
set(hm,'checked','on');
set(usd(1),'checked','off')
iduiclpw(usd(2));


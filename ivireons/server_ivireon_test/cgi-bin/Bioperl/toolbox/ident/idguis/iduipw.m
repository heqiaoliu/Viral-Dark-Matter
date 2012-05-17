function iduipw(arg,onoff)
%IDUIPW Callback for all plot windows in the ident GUI.
%   The function checks if the window called is on the screen.
%   If necessary created, and then filled with the relevant plots.
%
%   The input argument ARG is the number of the window
%   ONOFF tells whether the window should be Visible or not visible

%   L. Ljung 4-4-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2006/06/20 20:08:58 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

if nargin==2,set(XID.plotw(arg,2),'value',onoff),drawnow,end

if any(arg==[8,9,10,11])
    tes=1;
else
    tes=get(XID.plotw(arg,2),'value');
end
if tes,onoff='on';else onoff='off';end

h=iduiwok(arg);
if isempty(h)&tes,
    XID.plotw(arg,1)=idbuildw(arg);
    XID = get(Xsum,'UserData');
    h=XID.plotw(arg,1);
end
set(Xsum,'UserData',XID);

eval('set(h,''visible'',onoff);','')


if tes
    if any(arg==[1 2 3 4 5 6 7 13 40])
        if any(arg==[1,13,40])
            [act,cact]=fiacthad;
            if ~isempty(act)
                iduimod(arg,act,cact);
            end

        else
            [act,cact]=fiactham;
            if ~isempty(act)
                iduimod(arg,act,cact);
            end
        end
    end % if arg<8
end % if tes
iduistat('Click on data/model icons to plot/unplot curves.')

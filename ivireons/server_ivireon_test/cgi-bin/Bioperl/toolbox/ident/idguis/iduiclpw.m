function iduiclpw(figno,redraw,modno)
%IDUICLPW Clears lines in the plot windows
%   FIGNO:  The number of the plot window.
%   REDRAW: If this is equal to 1 the curves corresponding to active
%           models will be redrawn, otherwise not.
%   MODNO:  Numbers of models, whose lines shall be cleared. Default all.
%   The function also handles the corresponding UserData accordingly.

%   L. Ljung 4-4-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2009/01/20 15:32:39 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
if any(figno==[8]),return,end
iduistat('',0,figno);
if isempty(iduiwok(figno)),return,end
if nargin<3,modno=[];end


if nargin < 2, redraw=1;end
if strcmp(get(XID.plotw(figno,1),'vis'),'off'),redraw=0;end
iduital(figno);
xax=get(XID.plotw(figno,1),'UserData');[rxax,cxax]=size(xax);
xax=xax(3:rxax,1);
for kk=xax'
    xusd=get(kk,'userData');[rxusd,cxusd]=size(xusd);
    set(kk,'userdata',[]);
    if rxusd>2
        if isempty(modno),
            if figno==3
                rows=2:rxusd;
            else
                rows=3:rxusd;
            end
        else
            rows=[2*modno+1,2*modno+2];
        end
        try
            delete(idnonzer(xusd(rows,:)));
        end
        xusd(rows,:)=zeros(length(rows),cxusd);
    end
    set(kk,'UserData',xusd);
end
if figno==3
    %close(XID.plotw(3,1))
    fits=findobj(XID.plotw(3,1),'tag','fits');
    delete(fits)
end
if redraw
    if any(figno==[1,13,40]),actmod=fiacthad;
    elseif figno==14,actmod=0;
    elseif figno==15,actmod=[0,-1];
    else actmod=fiactham;end
    iduimod(figno,actmod);
end



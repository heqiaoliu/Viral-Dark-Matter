function idunlink(wino)
%IDUNLINK Performs the unlinking of figure with no wino.

%   L. Ljung 9-27-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2006/06/20 20:09:09 $

%global XIDplotw
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

axs=get(XID.plotw(wino,1),'children');
ax1=findobj(axs,'flat','tag','axis1');
ax2=findobj(axs,'flat','tag','axis2','vis','on');
newf=figure;
if isempty(ax2)
    subplot(111)
else
    subplot(211)
end
k=1;
for ax=[ax1,ax2'];
    if k==2,subplot(212),end
    axn=gca;
    set(axn,'xlim',get(ax,'xlim'),'ylim',get(ax,'ylim'),'box',get(ax,'box'),...
        'xscale',get(ax,'xscale'),'yscale',get(ax,'yscale'),...
        'xgrid',get(ax,'xgrid'),'ygrid',get(ax,'ygrid'),'color',get(ax,'color'))
    %     'dataaspectratio',get(ax,'dataaspectratio'),...

    xlo=get(ax,'xlabel');xln=get(axn,'xlabel');
    set(xln,'string',get(xlo,'string'),'vis',get(xlo,'vis'))
    xlo=get(ax,'ylabel');xln=get(axn,'ylabel');
    set(xln,'string',get(xlo,'string'),'vis',get(xlo,'vis'))
    xlo=get(ax,'title');xln=get(axn,'title');
    set(xln,'string',get(xlo,'string'),'vis',get(xlo,'vis'))
    lns=findobj(ax,'type','line','vis','on');
    for ln=lns(:)'
        line('xdata',get(ln,'xdata'),'ydata',get(ln,'ydata'),'color',...
            get(ln,'color'),'linestyle',get(ln,'linestyle'),...
            'marker',get(ln,'marker'))
    end
    k=k+1;
end

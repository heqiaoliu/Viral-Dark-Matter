function idopttog(arg,hm,replot)
%IDOPTTOG Toggles checked options.

%   L. Ljung 9-27-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2006/11/17 13:29:58 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
pw=gcf;
if nargin<3,replot=1;end
if nargin<2
    hm=gcbo;%get(pw,'currentmenu');
end
usd=get(hm,'userdata');

if strcmp(arg,'check')
    if strcmp(get(hm,'checked'),'on')&~strcmp(get(hm,'label'),...
            menulabel('&Spectral analysis'))
        return
    else
        set(hm,'checked','on');
        set(usd(1),'checked','off')
        optval=int2str(usd(4));
        userd=get(XID.plotw(usd(2),2),'userdata');
        [ru,cu]=size(userd);
        if usd(3)==1,newd=optval;else newd=deblank(userd(1,:));end
        for kk=2:ru
            if kk==usd(3);ite=optval;else ite=deblank(userd(kk,:));end
            newd=str2mat(newd,ite);
        end
        set(XID.plotw(usd(2),2),'userdata',newd);
        confflag=0;
        if strcmp(get(hm,'tag'),'predict')
            win=get(get(hm,'parent'),'parent');
            conf=findobj(win,'tag','confonoff');
            if strcmp(get(conf,'checked'),'on'),confflag=1;end
            set(conf,'enable','off');
        elseif strcmp(get(hm,'tag'),'simul')
            win=get(get(hm,'parent'),'parent');
            conf=findobj(win,'tag','confonoff');
            set(conf,'enable','on');
        elseif strcmp(get(hm,'tag'),'step')
            win = get(get(hm,'parent'),'parent');
            sst = findobj(win,'tag','stepsize');
            set(sst,'enable','on')
            elseif strcmp(get(hm,'tag'),'impulse')
            win = get(get(hm,'parent'),'parent');
            sst = findobj(win,'tag','stepsize');
            set(sst,'enable','off')
        end
        if replot,
            iduiclpw(usd(2));
            if confflag
                iduistat('No confidence intervals for predicted output.',0,3);
            end
        end
    end
elseif strcmp(arg,'set')
    optval=int2str(usd(3));
    userd=get(XID.plotw(usd(1),2),'userdata');
    [ru,cu]=size(userd);
    if usd(2)==1,newd=optval;else newd=deblank(userd(1,:));end
    for kk=2:ru
        if kk==usd(2);ite=optval;else ite=deblank(userd(kk,:));end
        newd=str2mat(newd,ite);
    end
    set(XID.plotw(usd(1),2),'userdata',newd);
    if usd(1)==3
        pre=findobj(gcf,'tag','predict');
        check=get(pre,'checked');

        set(pre,'label',menulabel([optval,' Step Ahead &Predicted Output']));
        if strcmp(check,'on')
            set(pre,'checked','on'),if replot iduiclpw(usd(1));end
        end
        return
    end
    if replot,iduiclpw(usd(1));end
elseif strcmp(arg,'unit_circle')
    huc=gcbo;%get(gcf,'currentmenu');
    onoff=get(huc,'checked');
    if strcmp(onoff,'on'),offon='off';else offon='on';end
    set(huc,'checked',offon);
    hl=findobj(XID.plotw(4,1),'tag','zpucl');
    if isempty(hl)&strcmp(offon,'on')
        iduistat('Unit circle will be drawn at next plot.',0,4);
        return
    end
    set(hl,'vis',offon);
elseif strcmp(arg,'reimaxes')
    huc=gcbo;%get(gcf,'currentmenu');
    onoff=get(huc,'checked');
    if strcmp(onoff,'on'),offon='off';else offon='on';end
    set(huc,'checked',offon);
    hre=findobj(XID.plotw(4,1),'tag','zpaxr');
    him=findobj(XID.plotw(4,1),'tag','zpaxi');
    if isempty(hre)&strcmp(offon,'on')
        iduistat('Axes will be drawn at next plot.',0,4);
        return
    end
    if strcmp(offon,'on')
        set(hre,'xdata',get(get(hre,'parent'),'xlim'));
        set(him,'ydata',get(get(hre,'parent'),'ylim'));
    end
    set([hre him],'vis',offon);
end

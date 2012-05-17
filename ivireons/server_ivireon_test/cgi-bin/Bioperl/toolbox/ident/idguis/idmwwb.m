function idmwwb(~)
%function [dat,dat_n,dat_i,do_com]=idmwwb(dum)

%IDMWWB Handles the window button callback in the main ident window.

%   L. Ljung 9-27-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.9 $ $Date: 2009/10/16 04:56:08 $

dat=[];dat_n=[];dat_i=[];do_com=[];

%if nargin>0,return,end
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

do_com='';dat=[];dat_n=[];dat_i=[];
seltyp=get(gcf,'Selectiontype');
curo=iduigco;
if strcmp(get(curo,'type'),'text')||strcmp(get(curo,'type'),'line')
    cura=get(curo,'parent');
elseif strcmp(get(curo,'type'),'axes')
    cura=curo;
elseif strcmp(get(curo,'type'),'uicontrol') && strcmp(get(curo,'tag'),'StatusEditField')
    return
else
    iduistat('Click acknowledged. No action invoked.');
    return
end
usd=get(cura,'tag');
if isempty(usd)
    return
elseif  strcmp(usd,'expor')
    iduistat('Drag data/model icon here to export it to workspace.')
    return
elseif  strcmp(usd,'ltivi')
    iduistat('Drag model icon here to study it in a LTI Viewer.')
    return
elseif  strcmp(usd,'seles')
    iduistat('Drag data icon here to select it as working data.')
    return
elseif  strcmp(usd,'selva')
    iduistat('Drag data icon here to select it as validation data.')
    return
elseif  strcmp(usd,'waste')&&strcmp(seltyp,'normal')
    iduistat(['Drag data/model icon here to delete it. Double click ',...
        '(right mouse button) to open can.'])
    return
end
line=findobj(cura,'type','line');
if strcmp(get(line(1),'vis'),'off')
    iduistat('Empty icon. No action invoked.')
    return
end
if length(usd)>5 kk=eval(usd(6:length(usd)));else kk=0;end
axtype=usd(1:5);

new = [];
if strcmp(seltyp,'open')||strcmp(seltyp,'alt')
    if strcmp(axtype,'waste')
        iduistat('Opening trash can ...')
        iduiwast('show');
    elseif strcmp(axtype,'model')||strcmp(axtype,'data ')
        iduistat('Opening text info ...')
        iduiedit('pres',cura);
        return
    else
        iduistat('Double click acknowledged.  No action invoked.'),return
    end
    iduistat('')
elseif strcmp(seltyp,'normal')
    if ~strcmp(axtype,'model')&&~strcmp(axtype,'data ')
        return
    end

    set(cura,'units','pixels')
    axpos=get(cura,'pos');
    iduistat('Drag and drop on another icon.')
    dragrect(axpos)

    iduistat('')
    set(cura,'units','norm')
    new = idmhit('axes');
    if isempty(new)
        new=idmhit('uicontrol');
        if ~isempty(new),if ~strcmp(get(new,'tag'),'modst'),new=[];end,end
    end
    if isempty(new),iduistat('Not dropped on another icon.  No action invoked.'),return,end
    if cura~=new,
        [dat,dat_n,dat_i,do_com]=iduidrop(cura,new);
        return
    end
end
if strcmp(seltyp,'normal')||strcmp(seltyp,'extend')
    lineobj=[findobj(cura,'tag','modelline');findobj(cura,'tag','dataline')];
    if isempty(lineobj),return,end
    lw=get(lineobj,'linewidth');
    
    noEvent = false;
    if strcmp(get(get(get(line,'parent'),'parent'),'tag'),'sitb34')
        noEvent = true;
    end
    
    Model = get(line,'userdata');
    if lw>1 % icone was in "selected state"
        onoff = 'off';
        nlw = 0.5;
        if ~noEvent && (isa(Model,'idnlarx') || isa(Model,'idnlhw'))
            if isa(Model,'idnlarx')
                evtype = 'nlarxDeactivated';
            else
                evtype = 'nlhwDeactivated';
            end
            % model deactivated event
            messenger = nlutilspack.getMessengerInstance('OldSITBGUI');
            ed = nlutilspack.idguievent(messenger,evtype);
            ed.Info = get(Model,'Name');
            messenger.send('identguichange',ed);
        end
    else
        onoff='on';
        nlw=3;
        if ~noEvent && (isa(Model,'idnlarx') || isa(Model,'idnlhw'))
            if isa(Model,'idnlarx')
                evtype = 'nlarxActivated';
            else
                evtype = 'nlhwActivated';
            end
            % model activated event
            messenger = nlutilspack.getMessengerInstance('OldSITBGUI');
            ed = nlutilspack.idguievent(messenger,evtype);
            ed.Info = struct('Model',Model,'isActive',true,'Color',get(line,'color'));
            messenger.send('identguichange',ed);
        end
    end
    if strcmp(onoff,'off')
        iduivis(get(cura,'userdata'),'off')
    else
        if strcmp(axtype,'model'),
            actfig=fiactha(XID.plotw(2:7,2))+1;
        else
            actfig=[];
            if get(XID.plotw(1,2),'value'),actfig=[actfig,1];end
            if get(XID.plotw(13,2),'value'),actfig=[actfig,13];end
            if get(XID.plotw(40,2),'value'),actfig=[actfig,40];end

        end
        if idIsValidHandle(new) && ~strcmp(get(get(new,'parent'),'tag'),'sitb34')
            iduimod(actfig,kk,[]);
        end
    end
    set(lineobj,'linewidth',nlw);
else
    iduistat('Click acknowledged. No action invoked.')
end

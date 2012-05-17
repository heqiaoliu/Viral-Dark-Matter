function handlenr=iduiinsm(Model,active,axinfo,import)
%IDUIINSM Handles the insertion of models into the Model Summary Board
%      Model:      The actual model, in theta-format or CRA or SPA model
%      model_info: The associated model information
%      model_name: The name (a string) of the model.
%      active:     If active==1 then the model should become active immediately
%      HANDLENR:   The handle number of the model pushbutton

%   L. Ljung 4-4-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.21.4.19 $ $Date: 2010/03/08 21:39:54 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
XID.OptimMessenger.Stop = false;
XID.counters(5)=1;
set(Xsum,'UserData',XID);

% remove Optim Messenger
if isa(Model,'idmodel') || isa(Model,'idnlmodel')
    Model = pvset(Model,'OptimMessenger',[]);
end

if isempty(Model),peflag=1;else peflag=0;end
if peflag
    mess=[...
        'There were numerical problems to compute the model.',...
        '\nThe model order might have been too high, or the input',...
        ' signal is not persistently exciting.',...
        ' Use other input or lower model orders.',...
        '\nNo model inserted.'];
    warndlg(mess);
    return
end
if nargin <4
    import = 0;
end

if nargin < 2,active=1;end
if active,iduistat('Model being inserted ...');end

if nargin<3
    axinfo =[];
end

if isempty(axinfo)
    [axh,texh,linh]=idnextw('model');
else
    [axh,texh,linh]=idnextw('model',axinfo(1),axinfo(2:5),axinfo(6:8));
    if isempty(linh),   [axh,texh,linh]=idnextw('model');end
end
XID = get(Xsum,'UserData');
tag=get(axh,'tag');
try
    set(XID.parest(3),'userdata',tag); %this will link the estimated model to ''by initial model''
end
modnr=eval(tag(6:length(tag)));
%theta_model=1;

if import
    chanupd(Model)
    XID = get(Xsum,'UserData');
end
dv = iduigetd('v');
switch class(Model)
    case 'idfrd'
        [~,nu]=size(Model);
        if nu>0
            set(XID.plotw([2,7],2),'enable','on')
        else
            set(XID.plotw(7,2),'enable','on')
        end
        mmp=Model;
        lpl = pvget(mmp,'ResponseData');
        if isempty(lpl)
            lpl = pvget(mmp,'SpectrumData');
        end
        lpl = abs(squeeze(lpl(1,1,:)));
        if any(isnan(lpl))
            warndlg(char({'There were numerical difficulties in calculating the frequency',...
                'response. Probably the resolution parameter was too large,'}))
            return
        end
        Model_name = pvget(Model,'Name');
    otherwise
        %if strcmp(get(XID.plotw(3,2),'enable'),'off')
        set(XID.plotw([4:5,7],2),'enable','on')
        if ~isempty(dv)
            set(XID.plotw([3,6],2),'enable','on')
        end
        %end
        [ny,nu] = size(Model);
        if nu >0
            set(XID.plotw(2,2),'enable','on')
        else
            % dv = iduigetd('v','me');
            if ~isempty(dv) && isa(dv,'iddata') && strcmpi(pvget(dv,'Domain'),'time')
               set(XID.plotw(3,2),'enable','on')
            else
               set(XID.plotw(3,2),'enable','off')
            end
        end
        if isa(Model,'idmodel') && ~(isaimp(Model) || isa(Model,'idpoly'))
            Model = setcov(Model); % to do these calc once and for all
        end

        Model_name = pvget(Model,'Name');
        pars = getParameterVector(Model);
        peflag = any(~isfinite(pars)); % isnan(pars))|any(isinf(pars));
        if peflag
            mess=(...
                ['There were numerical problems in computing the model. Model contains non-finite parameter values.',...
                'The model order might have been too high, or the input signal is not persistently exciting. ',...
                'Use other input or lower model orders. No model inserted.']);
            warndlg(mess);
            return
        end
        Ts = pvget(Model,'Ts');
        if Ts==0
            ut = pvget(Model,'Utility');
            try
                Td = ut.Tsdata;
            catch
                try
                    es = pvget(Model,'EstimationInfo');
                    Td = es.DataTs;
                catch
                    Td = [];
                end
                if isempty(Td),
                    if isa(Model,'idmodel')
                        [~,Td] = iddeft(Model);
                    end
                else
                    Td = 1;
                end
                ut.Tsdata = Td;
                Model = pvset(Model,'Utility',ut);
            end
        end
        if isaimp(Model)
            lpl = pvget(Model,'B');
            lpl = squeeze(lpl(1,1,:));
            llpl = length(lpl);
            if llpl>35
                lpl = lpl(11:35);
            end
            %         elseif isa(Model,'idnlgrey')
            %             was = warning('off');
            %             lpl = sim(Model,[[1;zeros(24,1)],zeros(25,max(nu+ny-1,0))]);
            %             warning(was)
        else
            ctrlMsgUtils.SuspendWarnings;
            try
                if Model.Ts==0
                    % c2d(Model,1) need not work depending upon model's
                    % time constants; hence sim(Model, [1,0,...0]) need not
                    % work.
                    try
                        lpl = impulse(Model);
                    catch
                        % impulse fails for IDNLGREY; might fail for other
                        % models too
                        lpl = step(Model);
                    end
                else
                    try
                        lpl = sim(Model,[[1;zeros(24,1)],zeros(25,max(nu+ny-1,0))]);
                    catch
                        lpl = step(Model);
                    end
                end
            catch
                warndlg('Simulation of model using impulse and step inputs failed. The model may not be usable.')
                lpl = rand(25,1);
            end
        end

end
if ~isreal(lpl),
    lpl=abs(lpl);
end
if isa(Model,'idnlarx') || isa(Model,'idnlhw')
    %check uniqueness
    Model_name = nlutilspack.generateUniqueModelName(class(Model),get(Model,'Name'));
    if ~strcmp(Model_name,get(Model,'name'))
        set(Model,'Name',Model_name);
        msgbox('Model name(s) changed to ensure uniqueness of names.',...
            'Nonlinear Model Name Change','warn','replace')
    end
end

lpl=lpl(:,1);
set(axh,'vis','off')
set(linh,'UserData',Model,'tag','modelline')
set(texh,'String',Model_name,'vis','on')
handlenr=axh;
%set(texh,'UserData',model_info)

set(linh,'xdata',1:length(lpl),'ydata',lpl,'vis','off');
Plotcolors=idlayout('plotcol');
if isa(Model,'idnlhw')
    axescolor = Plotcolors(10,:);
    %axescolor = [0.831 0.816 0.784];
elseif isa(Model,'idnlarx')
    axescolor = Plotcolors(9,:);
    %axescolor = [0.88 0.87 0.85];
else
    axescolor = Plotcolors(4,:);
end

ylim = [2*min(lpl)-max(lpl) max(lpl)];
if ylim(1)>=ylim(2),
    ylim = [ylim(1)-1 ylim(2)+1];
end
try
    set(axh,'ylim',ylim,'xlim',[0 length(lpl)],...
        'color',axescolor);
catch
    errordlg('Failed to insert model.','Error Dialog','modal');
    set(axh,'vis','on')
    set(linh,'UserData',Model,'tag','')
    set(texh,'String','','vis','on')
    return
end
if active,
    set(linh,'linewidth',3);
end
set(linh,'vis','on')
set(axh,'vis','on')

if active
    Figno = fiactha(XID.plotw(2:7,2))+1;
    iduimod(Figno,modnr,[])
    set(XID.sbmen([3 5]),'enable','on')
    if strcmp(get(XID.sbmen(1),'tag'),'open')
        [label,acc] = menulabel('&Merge session... ^o');
        set(XID.sbmen(1),'label',label,'tag','merge');
    end
end

iduistat(['Model ',Model_name,' inserted. ',...
        'Double click on icon for text information.']); 

if isa(Model,'idnlarx') || isa(Model,'idnlhw')

    % broadcast model addition event for the benefit of nonlinear plots and estimation GUI
    if isa(Model,'idnlarx')
        evtype = 'nlarxAdded';
    else
        evtype = 'nlhwAdded';
    end
    messenger = nlutilspack.getMessengerInstance('OldSITBGUI');
    ed = nlutilspack.idguievent(messenger,evtype);
    ed.Info = struct('Model',Model,'isActive',active==1,'Color',get(linh,'color'));
    messenger.send('identguichange',ed);

    % update main ident GUI itself
    c = findall(Xsum,'style','checkbox','tag',class(Model));
    set(c,'enable','on');
end


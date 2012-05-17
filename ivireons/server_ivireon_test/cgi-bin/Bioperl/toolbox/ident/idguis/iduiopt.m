function iduiopt(arg,window,number,optno,procflag)%,optval,figno,con,coff)
%IDUIOPT Handles the setting of all options.
%   The arguments are as follows
%   window is the window we are working with
%   number is the menu-item (similar) that we are addressing within this window
%   handno is the handle number that holds the options as userdata
%          It is a vector of length=no of options to be handled
%   optno is a vector containing the option numbers to be handled currently
%   handno is placed as userdata of the window
%   optno is placed as userdata of the respective edit ui the plotwindow
%          (if applicable) to be refreshed upon return is placed as userdata
%          of the first text edit window (no 4)
%   ARG
%   dlg_freq   Options for frequency responses and spectra
%   dlg_nos    Number of samples for transient response
%   dlg_dec    Decimation factor
%   dlg_ioopt  Options associated with the iterative search
%   dlg_lgs    No of lags in residual analysis
%   dlg_ph     Prediction horizon in COMPARE plot
%   dlg_sampff Setting the sample numbers to be used in fit calculation
%   apply      Lets the options take action. Places the info at the
%              appropriate userdata and refreshes the plot

%   L. Ljung 4-4-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.16.4.10 $ $Date: 2009/10/16 04:56:15 $

%global   XIDopt XIDplotw XIDparest  XIDss XIDlayout
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
if nargin<5
    procflag = 0;
end
if strcmp(window,'plotw')
    handno=XID.plotw(number,2);
elseif strcmp(window,'handle')
    handno=number(1);
elseif strcmp(window,'ioopt')
    handno=XID.citer(1);
elseif strcmp(window,'ssopt')
    handno=XID.ss(1,6);
elseif strcmp(window,'men')
    handno=XID.plotw(16,1);
end

usd=get(handno,'UserData');

vDato = iduigetd('v');
if isa(vDato,'idfrd') || strcmpi(vDato.Domain(1),'f')
    str0 = 'frequency';
    unitstr = get(vDato,'Units');
else
    str0 = 'time';
    unitstr = vDato.TimeUnit;
    if isempty(unitstr)
        unitstr = 'sec';
    end
end


if strcmp(arg(1:3),'dlg')
    Isdlg_ioopt = strcmp(arg,'dlg_ioopt');
    no_of_opt=length(optno);
    tag=['sitb',int2str(22+no_of_opt)];
    f=findobj(allchild(0),'flat','tag',tag);
    %figname=idlaytab('figname',22+no_of_opt);
    if isempty(f)
        iduistat('Opening the dialog box...')
        idlayoutscript
        butw=mStdButtonWidth;buth=mStdButtonHeight;
        etf = mEdgeToFrame;
        FigW = iduilay2(3);
        
        f = figure('vis','off',...
            'NumberTitle','off','HandleVisibility','callback',...
            'Integerhandle','off', ...
            'DockControls','off',...
            'Color',get(0,'DefaultUIControlBackgroundColor'),'tag',tag);
        XID.opt(1,no_of_opt) = f;
        set(f,'Menubar','none');
        
        % LEVEL1
        
        pos = iduilay1(FigW,3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        uicontrol(f,'Pos',pos(2,:),'style','push',...
            'string','Apply','callback',['iduipoin(1);',...
            'iduistat(''compiling...'');',...
            'iduiopt(''apply'',''handle'',get(gcf,''UserData''));',...
            'iduistat(''Option updated'');iduipoin(2);']);
        uicontrol(f,'Pos',pos(3,:),'style','push',...
            'callback','set(gcf,''visible'',''off'')','string','Close');
        XID.opt(2,no_of_opt)=uicontrol(f,'Pos',...
            pos(4,:),'style','push','string','Help');
        
        % LEVEL 2
        lev = pos(1,2)+pos(1,4);twono=2*no_of_opt;
        pos = iduilay1(FigW,twono,twono,lev,[],3);
        uicontrol(f,'pos',pos(1,:),'style','frame');
        if Isdlg_ioopt
            no_of_opt1 = 5;
            boxno = 6;
            XID.opt(boxno*2+1,no_of_opt)=...
                uicontrol(f,'pos',pos(twono+3-2*boxno,:)+[0 5 0 0],'style','popup',...
                'HorizontalAlignment','left','backgroundcolor','white',...
                'String',{'Determinant','Trace'},'callback',{@LocalCriterionChange,Xsum});
            boxno = 7;
            SearchMethods = {'Choose Automatically (Auto)','Gauss-Newton (gn)','Adaptive Gauss-Newton (gna)',...
                'Levenberg-Marquardt (lm)','Trust-Region Reflective Newton (lsqnonlin)',...
                'Gradient Search (grad)'};
            XID.opt(boxno*2+1,no_of_opt)=...
                uicontrol(f,'pos',pos(twono+3-2*boxno,:)+[0 5 0 0],'style','popup',...
                'HorizontalAlignment','left','backgroundcolor','white',...
                'String',SearchMethods,'callback',{@LocalSearchMethodChange, Xsum});
        else
            no_of_opt1 = no_of_opt;
        end
        
        % edit boxes
        for boxno = 1:no_of_opt1
            %        lev = pos(1,2)+pos(1,4);
            XID.opt(boxno*2+1,no_of_opt)=...
                uicontrol(f,'pos',pos(twono+3-2*boxno,:)+[0 5 0 0],'style','edit',...
                'HorizontalAlignment','left','backgroundcolor','white');
        end
        
        %labels
        for boxno = 1:no_of_opt
            XID.opt(boxno*2+2,no_of_opt)=...
                uicontrol(f,'pos',pos(twono+2-2*boxno,:),'style','text',...
                'HorizontalAlignment','left');
        end
        poslev=pos(1,2)+pos(1,4);
        FigWH=[FigW poslev+mEdgeToFrame];
        ScreenPos = get(0,'ScreenSize');
        FigPos=[(ScreenPos(3:4)-FigWH)/2 FigWH];
        set(f,'pos',FigPos);
        iduiadj(f);%set(get(f,'children'),'units','norm'); set(get(f,'children'),'unit','norm')
        laynum=no_of_opt+22;
        if length(XID.layout)>29
            if XID.layout(laynum,3)
                eval('set(f,''pos'',XID.layout(laynum,1:4))','')
            end
        end
    else
        figure(f(1))
    end
    set(XID.opt(1,no_of_opt),'UserData',[handno;no_of_opt],'vis','on')
    iduistat('Ready to change options.')
    set(Xsum,'UserData',XID);
    
end

if strcmp(arg,'dlg_freq')
    set(XID.opt(2,1),'callback','iduihelp(''idfreq.hlp'',''Frequency Values'');')
    set(XID.opt(4,1),'string','Enter row vector with frequency values (rad/s)',...
        'UserData',number);
    set(XID.opt(3,1),'string',deblank(usd(optno,:)),'UserData',optno)
    set(XID.opt(1,1),'name','Set Frequency Range')
elseif strcmp(arg,'dlg_nos')
    set(XID.opt(1,1),'name', 'Set Time Span');
    set(XID.opt(2,1),'callback','iduihelp(''idnos.hlp'',''Time Span'');')
    set(XID.opt(4,1),'string','Set time span (in TimeUnits) for transient response',...
        'UserData',5);
    set(XID.opt(3,1),'string',deblank(usd(optno,:)),'UserData',optno)
elseif strcmp(arg,'apply')
    no_of_opt=number(2);
    for boxno=1:no_of_opt
        obj=XID.opt(boxno*2+1,no_of_opt);
        optno=get(obj,'UserData');
        testusd = 1;
        if strcmp(get(obj,'Style'),'popupmenu')
            sl1=int2str(get(obj,'value'));
            test = 1;
        else
            sl1=deblank(get(obj,'string'));
            if isempty(sl1)
                test = [];
            elseif strcmpi(sl1,'default')
                test = [];
            elseif strncmpi(sl1,'for process',11) % This is just to handle "For process ..."
                test = 1;
                testusd = [];
            else
                test = evalin('base',['[',sl1,']'],'-1');
                if isempty(test)
                    test = [];
                end
            end
            
            if ischar(test)&(lower(test(1))=='d'|all(test==' ')|isempty(eval(test)))
                test = [];
            end
            if isempty(test)
                set(obj,'String','Default');
                sl1 = 'Default';
            else
                
                if isa(test,'double')&test(1)<0 % & what?
                    errordlg('Only positive values can be entered for this option.',...
                        'Error Dialog','modal');
                    set(obj,'string','Default')
                    return
                end
            end
        end
        if isempty(test) || isempty(testusd),sl1='[]';end
        %if isempty(eval(sl1)),sl1='[]';end
        [rsl1,csl1]=size(sl1);
        [rusd,cusd]=size(usd);
        if csl1>cusd
            usd=[usd,zeros(rusd,csl1-cusd)];
        end
        if csl1<cusd
            sl1=[sl1,zeros(1,cusd-csl1)];
        end
        usd(optno,:)=sl1;
    end
    set(handno,'UserData',usd)
    figno=get(XID.opt(4,no_of_opt),'UserData');
    type=get(XID.opt(1,no_of_opt),'name');
    if ~isempty(figno)
        if figno>1
            if ~strcmp(type,'Set Prediction Horizon'),iduiclpw(figno),end
        end
    end
    if strcmp(type,'Set Prediction Horizon')
        men=findobj(XID.plotw(3,1),'tag','predict');
        onoff=get(men,'checked');
        if isempty(test),kstep=int2str(5);else kstep=deblank(sl1);end
        [label,acc]=menulabel([kstep,' step ahead &predicted output ^p']);
        set(men,'label',label,'checked',onoff);
        if strcmp(onoff,'on'),iduiclpw(3);end
        %          xax=get(XID.plotw(3,1),'UserData');
    end
elseif strcmp(arg,'dlg_ioopt')
    set(XID.opt(2,7),'callback','iduihelp(''idioopt.hlp'',''Iteration Options'');');
    for kk = 1:7
        str1 = deblank(usd(kk,:));
        if strcmp(str1,'[]')
            str1 = 'Default';
        end
        if kk<=5
            set(XID.opt(2*kk+1,7),'string',str1,'UserData',kk);
        else
            set(XID.opt(2*kk+1,7),'UserData',kk);
        end
    end
    
    set(XID.opt(16,7),'string','Search Method','UserData',7);
    set(XID.opt(14,7),'string','Minimization Criterion','UserData',6);
    set(XID.opt(12,7),'string','Weighting: (Positive semi-definite matrix, Default: eye(ny))','UserData',5);
    
    if procflag
        %NuNy = get(XID.procest(1,1),'userdata');
        set(XID.opt(10,7),'string',...
            'FixedParameter:','UserData',4)
        set(XID.opt(9,7),'style','text','BackgroundColor',...
            get(0,'DefaultUIControlBackgroundColor'),'string',...
            'For Process Models, use the checkbox ''Known''.')
    else
        %NuNy = get(XID.parest(1),'userdata');
        set(XID.opt(10,7),'string',...
            'FixedParameter. (Default: None)','UserData',4)
        set(XID.opt(9,7),'style','edit','BackgroundColor',...
            'w','tooltip',['Enter the numbers or names of the parameters that should be fixed. ',...
            'Use cell arrays for names.'])
    end
    set(XID.opt(8,7),'string',...
        'MaxIter: Maximum number of iterations (Default: 20)','UserData',3)
    set(XID.opt(6,7),'string',...
        'Tolerance: Termination tolerance (Default 0.0:1)','UserData',2)
    set(XID.opt(4,7),'string','LimitError: Robustification limit (Default: 0)',...
        'UserData',1)
    set(XID.opt(1,7),'name',str2mat(...
        'Options for Iterative Minimization'))
    
    LocalSearchMethodChange(XID.opt(15,7),[],Xsum);
    
    %{
    % todo: do this?
    if NuNy(2)==1
        %disable Criterion and Weighting options
        set(XID.opt(13,7),'Value',1,)
    else
        % enable
    end
    %}
    
elseif strcmp(arg,'dlg_lgs')
    set(XID.opt(2,1),'callback','iduihelp(''idlgs.hlp'',''Number of Lags'');');
    set(XID.opt(1,1),'name','Set Number of Lags')
    set(XID.opt(4,1),'string','Number of correlation lags','UserData',6);
    set(XID.opt(3,1),'string',deblank(usd(optno,:)),'UserData',optno)
    
elseif strcmp(arg,'dlg_ph')
    set(XID.opt(2,1),'callback','iduihelp(''idpredh.hlp'',''Prediction Horizon'');')
    set(XID.opt(1,1),'name','Set Prediction Horizon')
    set(XID.opt(4,1),'string','Prediction horizon (in samples)',...
        'UserData',3);
    set(XID.opt(3,1),'string',deblank(usd(optno,:)),'UserData',optno)%%
    
elseif strcmp(arg,'dlg_sampff')
    set(XID.opt(2,1),'callback','iduihelp(''idsampff.hlp'',''Time/Frequency Span for Fit'');')
    set(XID.opt(1,1),'name',[upper(str0(1)),str0(2:end),' Span'],'pos',get(XID.opt(1,1),'pos')+[0 0 10 0])
    
    msg = sprintf('Specify %s span (in %s) for fit %% computation.',str0,unitstr);
    set(XID.opt(4,1),'string',msg,'UserData',3);
    set(XID.opt(3,1),'string',deblank(usd(optno,:)),'UserData',optno)
    
end

%--------------------------------------------------------------------------
function LocalSearchMethodChange(es,ed,Xsum)
% only trace criterion can be handled by lsqnonlin 

XID = get(Xsum,'Userdata');
v = get(es,'Value');
if v==5
    %lsqnonlin-> set criterion to "trace"
    set(XID.opt(13,7),'value',2,'enable','off');
    set(XID.opt(11,7),'enable','on'); %weighting
else
    set(XID.opt(13,7),'enable','on');
end

LocalCriterionChange(XID.opt(13,7),[],Xsum)

%--------------------------------------------------------------------------
function LocalCriterionChange(es,ed,Xsum)
% for DET criterion, weighting should be disabled

XID = get(Xsum,'Userdata');
v = get(es,'Value');
if v==1
    set(XID.opt(11,7),'enable','off'); %weighting
else
    set(XID.opt(11,7),'enable','on');
end



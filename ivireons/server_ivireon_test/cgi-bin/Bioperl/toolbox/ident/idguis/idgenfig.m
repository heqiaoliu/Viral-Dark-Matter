function idgenfig(models,figures)
%IDGENFIG Generates all view curves for ident.
%   The function generates all curves associated with models MODELS
%   in view windows FIGURES. The handle numbers of these curves are
%   stored in the userdata of the corresponding axes, so that row
%   number 2*K+1 of the userdata contains the handles of lines
%   associated with model number K, while row 2*K+2 contains the
%   corresponding confidence interval lines

%   L. Ljung 4-4-94
%   Copyright 1986-2009 The MathWorks, Inc.
%    $Revision: 1.33.4.18 $  $Date: 2009/10/16 04:56:07 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
XIDplotw = XID.plotw;
XIDsumb = XID.sumb;
%warflag = strcmp(get(XID.warning,'checked'),'on');
hnr=[]; gc=[];
wb = []; %waitbar

Plotcolors=idlayout('plotcol');
textcolor=Plotcolors(6,:);  %To be used for validation data and outlines

sumbs=findobj(allchild(0),'flat','tag','sitb30');
modaxs=get(XIDsumb(1),'children');
for kk=sumbs(:)'
    modaxs=[modaxs;get(kk,'children')];
end
chmess='Model(s) incompatible with chosen channels.';
chmess2='Model(s) incompatible with chosen channel.';
ctrlMsgUtils.SuspendWarnings; 

for Figno=figures
    hsd=findobj(XIDplotw(Figno,1),'tag','confonoff');
    SD=get(hsd,'Userdata');
    figure(XIDplotw(Figno,1)); set(0,'CurrentFigure',XIDplotw(Figno,1));
    gcaa = get(XIDplotw(Figno,1),'CurrentAxes');
    xusd=get(XIDplotw(Figno,1),'Userdata');
    xax=xusd(3:length(xusd));
    if isempty(get(xax(1),'children')),newplot=1;else newplot=0;end %%LL
    Opthand=XIDplotw(Figno,2);
    opt=get(Opthand,'UserData');
    
    [kydes,kudes]=iduiiono('unpack',Figno);
    if Figno==2   % This is the Bode Case
        iduistat('Computing Frequency response...')
        w=eval(deblank(opt(4,:)));
        %[rw,cw]=size(w);if cw>rw, w=w'; rw=cw;end,if rw==0,rw=128;end
        hz=eval(opt(3,:))-1;
        plx=eval(opt(1,:))-1;
        ply=eval(opt(2,:))-1;
        for k=models
            isconf=1;
            doplot=1;docalc=1;
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            
            if nu==0&&~(isempty(ku)||isempty(ku))
                errordlg(['The model ',name,' is a time series model.',...
                    '\nUse ''Noise spectrum'' in place of the ''Frequency resp'' plot.'],...
                    'Time Series Model','modal');
                docalc=0;doplot=0;
                figure(XIDplotw(Figno,1)),
            elseif isempty(ku)||isempty(ky)
                iduistat(chmess,0,Figno);
                docalc=0;doplot=0;  figure(XIDplotw(Figno,1)),
            end
            gc=[];
            if docalc
                nam = 'dum';
                if isa(model,'idnlhw')
                    %model = getlinmod(model);
                    iduistat('No frequency response for Hammerstein-Wiener models.',0,Figno);
                    doplot=0;
                elseif isa(model,'idnlarx')
                    iduistat('No frequency response for Nonlinear ARX models.',0,Figno);
                    doplot=0;
                elseif isa(model,'idnlgrey')
                    iduistat('No frequency response for Nonlinear Grey-Box models.',0,Figno);
                    doplot=0;
                end
                if isa(model,'idfrd')
                    gc=model;
                    es = pvget(gc,'EstimationInfo');
                    nam = 'spa';
                    if strcmpi(es.Method,'etfe')
                        isconf = 0;
                    end
                    [ggw,gga,ggp,ggsda,ggsdp]=getff(gc,ku,ky);
                elseif ~isaimp(model) && ~isa(model,'idnlmodel')
                    [gga,ggp,ggw,ggsda,ggsdp]=boderesp(model,w);
                    gga=squeeze(gga(ky,ku,:));
                    ggp=squeeze(ggp(ky,ku,:));
                    if ~isempty(ggsda),
                        ggsda=squeeze(ggsda(ky,ku,:));
                        if norm(ggsda)==0
                            isconf = 0;
                        end
                    else
                        isconf = 0;
                    end
                    if ~isempty(ggsdp),
                        ggsdp=squeeze(ggsdp(ky,ku,:));
                    end
                elseif isaimp(model)
                    iduistat('No frequency response for Impulse Response model.',0,Figno);
                    doplot=0;
                end
            end %if docalc
            axes(xax(1))
            xusd1=get(xax(1),'UserData');set(xax(1),'userdata',[]);
            if doplot
                
                if isempty(ggsda),isconf=0;end
                if hz, ggw=ggw/2/pi;end
                if plx, set(xax(1),'Xscale','log'),else set(xax(1),'Xscale','linear'),end
                if ply, set(xax(1),'Yscale','log'),else set(xax(1),'Yscale','linear'),end
                color = get(klin,'color');
                xusd1(2*k+1,1) = line(ggw,gga,'color',color,...
                    'visible','off','userdata',kstr,'parent',xax(1));
                hnr = xusd1(2*k+1,1);
                if isconf
                    xusd1(2*k+2,1:2)=line([ggw ggw],[gga+SD*ggsda max(gga-SD*ggsda,0)],...
                        'color',color,'linestyle','-.',...
                        'Visible','off','userdata',kstr,'tag','conf','parent',xax(1))';
                    hnr=[hnr,xusd1(2*k+2,1:2)];
                else
                    
                    if strcmp(nam(1:3),'spa')
                        noconf=-2;
                    else
                        noconf=-1;
                    end
                    xusd1(2*k+2,1:2)=[noconf,noconf];
                end
            else
                xusd1(2*k+1,1)=-1;
            end %if doplot
            set(xax(1),'userData',xusd1);
            if doplot
                axes(xax(2))
                xusd2 = get(xax(2),'UserData');set(xax(2),'userdata',[]);
                if plx, set(xax(2),'Xscale','log'),else set(xax(2),'Xscale','linear'),end
                xusd2(2*k+1,1) = line(ggw,ggp,'color',color,...
                    'visible','off','userdata',kstr,'parent',xax(2));
                hnr=[hnr,xusd2(2*k+1,1)];
                if isconf
                    xusd2(2*k+2,1:2)=line([ggw ggw],[ggp+SD*ggsdp ggp-SD*ggsdp],...
                        'color',color,'linestyle','-.',...
                        'Visible','off','userdata',kstr,'tag','conf','parent',xax(2))';
                    hnr=[hnr,xusd2(2*k+2,1:2)];
                else
                    if strcmpi(nam(1:3),'spa');
                        noconf=-2;
                    else
                        noconf=-1;
                    end
                    xusd2(2*k+2,1:2)=[noconf,noconf];
                end
                set(xax(2),'userdata',xusd2)
                usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                set(khax,'userdata',usd);
                
            end %if doplot
        end % for models
    elseif Figno==7,   % This is the Spectrum Case
        iduistat('Computing Spectra...')
        w=eval(deblank(opt(4,:)));
        %[rw,cw]=size(w);if cw>rw, w=w'; rw=cw;end,if rw==0,rw=128;end
        hz=eval(opt(3,:))-1;
        plx=eval(opt(1,:))-1;
        ply=eval(opt(2,:))-1;
        for k=models
            isconf=1;
            doplot=1;docalc=1;
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            if isempty(ky)
                iduistat(chmess2,0,Figno);
                docalc=0;doplot=0;  figure(XIDplotw(Figno,1)),
                
            end
            if isa(model,'idnlmodel')
                doplot = 0;docalc = 0;
                iduistat('No noise spectra for nonlinear models.',0,Figno);
            end
            if docalc
                nam='dum';
                if isa(model,'idfrd')
                    g=model;spe=g('n');
                    [ggw,gga,dum,ggsda,dum]=getff(spe,0,ky); %%LL%% add w here
                    if isempty(gga)
                        doplot=0;
                        iduistat(['No spectrum for model ',pvget(model,'Name'),'.'],0,Figno);
                    end
                    es = pvget(g,'EstimationInfo');
                    if strcmpi(es.Method,'etfe')
                        isconf=0;
                        if nu>0
                            iduistat('No disturbance spectrum for EFTE model.',0,Figno);
                            doplot=0;
                        end
                    end
                    if norm(ggsda)==0
                        isconf =  0;
                    end
                    
                elseif ~isaimp(model)
                    spe = model('n');
                    [gga,dum,ggw,ggsda,dum]=boderesp(spe,w);
                    if isempty(gga)
                        doplot=0;
                        iduistat(['No spectrum for model ',pvget(model,'Name'),'.'],0,Figno);
                    end
                    gga=squeeze(gga(ky,ky,:));
                    if ~isempty(ggsda), ggsda=squeeze(ggsda(ky,ky,:));end
                    if norm(ggsda)==0
                        isconf =  0;
                    end
                else
                    iduistat('No spectrum for IMPULSE RESPONSE model.',0,Figno);
                    doplot=0;
                end
            end % if docalc
            axes(xax(1))
            xusd1=get(xax(1),'UserData');set(xax(1),'UserData',[]);
            if doplot
                
                if isempty(ggsda),isconf=0;end
                if hz, ggw=ggw/2/pi;end
                if plx, set(xax(1),'Xscale','log'),else set(xax(1),'Xscale','linear'),end
                if ply, set(xax(1),'Yscale','log'),else set(xax(1),'Yscale','linear'),end
                color=get(klin,'color');
                xusd1(2*k+1,1)=line(ggw,gga,'color',color,...
                    'visible','off','userdata',kstr,'parent',xax(1));
                hnr = xusd1(2*k+1,1);
                if isconf
                    xusd1(2*k+2,1:2) = line([ggw ggw],[gga+SD*ggsda max(gga-SD*ggsda,0)],...
                        'color',color,'linestyle','-.',...
                        'Visible','off','userdata',kstr,'tag','conf','parent',xax(1))';
                    hnr = [hnr,xusd1(2*k+2,1:2)];
                else
                    if strcmp(nam(1:3),'spa')
                        noconf=-2;
                    else
                        noconf=-1;
                    end
                    xusd1(2*k+2,1:2)=[noconf,noconf];
                end
                usd = [idnonzer(get(khax,'userdata')); hnr(:)];
                set(khax,'userdata',usd);
            else
                xusd1(2*k+1,1)=-1;
            end %if doplot
            set(xax(1),'userData',xusd1);
            
        end % for models
        
    elseif Figno==3   % This is Compare
        if any(models==0)
            iduistat('Adjusting fit table ...',0,3);
        else
            wb = waitbar(0,'Computing simulation/prediction ...');
            iduistat('Computing simulation/prediction ...')
            
            if isempty(get(gcaa,'children')) %%LL
                newplot=1;
            else
                newplot=0;
            end
            try
                [vDato,~,vDat_name,kv] = iduigetd('v');
                if isa(vDato,'idfrd')
                    frdflag = 1;
                    vDato = iddata(vDato,'me');
                    kdesu = find(strcmp(pvget(vDato,'InputName'),kudes));
                    if isempty(kdesu)
                        errordlg(['Model output views are not supported for ',...
                            'frequency function data with no input.'],...
                            'Error Dialog','modal');
                        if idIsValidHandle(wb), close(wb), end
                        return
                    end
                    vDato = getexp(vDato,kdesu);
                else
                    frdflag = 0;
                end
                dom = pvget(vDato,'Domain');dom = lower(dom(1));
                
            catch
                errordlg('A validation data set must be supplied',...
                    'Error Dialog','modal')
                if idIsValidHandle(wb), close(wb), end
                return
            end
            if dom=='f'
                hz = 0;plx = 1; ply = 1;
                hand = XID.plotw(3,1);
                try
                    hzh = findobj(hand,'tag','hz');
                    if strcmp(get(hzh,'checked'),'on')
                        hz = 1;
                    end
                end
                try
                    hzh = findobj(hand,'tag','linfreq');
                    if strcmp(get(hzh,'checked'),'on')
                        plx = 0;
                    end
                end
                try
                    hzh = findobj(hand,'tag','linamp');
                    if strcmp(get(hzh,'checked'),'on')
                        ply = 0;
                    end
                end
            end
            
            yv=pvget(vDato,'OutputData');uv=pvget(vDato,'InputData');
            if length(yv)>1&&~frdflag % multiple experiments
                expnr = iduiexp('find',3,pvget(vDato,'ExperimentName'));
            else
                expnr = 1;
            end
            if isempty(expnr)
                errordlg(['The experiment selected in the model output view is not present',...
                    ' in the validation data'],'Error Dialog', 'modal');
                if idIsValidHandle(wb), close(wb), end
                return
            end
            
            yv = yv{expnr}; uv =uv{expnr};
            %dny = size(yv,2);
            dnu = size(uv,2);
            vDat =[yv,uv];
            TSamp = pvget(vDato,'Ts');TSamp =TSamp{expnr};
            
            t0 = pvget(vDato,'Tstart');t0 = t0{expnr};
            %{
            inters = pvget(vDato,'InterSample');
            try
                inters = inters{1,kexp};
            catch
                inters = 'zoh';
            end
            %}
            
            dky = find(strcmp(pvget(vDato,'OutputName'),kydes));
            if isempty(dky)
                errordlg(['The validation data ',vDat_name,' does not contain ',...
                    'the chosen output channel for the model output plot.'],'Error Dialog','modal');
                %docalc=0;doplot=0;
                if idIsValidHandle(wb), close(wb), end
                return
            end
            %unad = pvget(vDato,'InputName');
            %ynad = pvget(vDato,'OutputName');
            dom = pvget(vDato,'Domain');
            dom = lower(dom(1));
            gc=vDat(:,dky);
            yval=gc;
            try
                PH=eval(opt(1,:));
            catch
                PH=0;
            end
            if isempty(PH),PH=5;end
            if length(PH)>1 || PH(1)<1 || floor(PH(1))~=PH(1)
                errordlg('The prediction horizon must be a positive integer.','Error Dialog','modal');
                if idIsValidHandle(wb), close(wb), end
                return
            end
            
            isdiff = eval(opt(4,:));
            if eval(opt(2,:))==2
                ISSim = 0;
            else
                ISSim = 1;
            end
            if isinf(PH),ISSim=1;end
            if ISSim, PH = inf; end
            if dnu==0&&ISSim,
                hmpred = findobj(XIDplotw(3,1),'tag','predict');
                hmsim = findobj(XIDplotw(3,1),'tag','simul');
                idopttog('check',hmpred);
                set(hmsim,'enable','off');
                if idIsValidHandle(wb), waitbar(1,wb), close(wb), end
                return;
            end
            flag=0;
            try
                sumsamp = evalin('base',['[',deblank(opt(3,:)),']']);
            catch
                flag = 1;
            end
            if dom=='t'
                strdomaintype = 'time';
                sa = pvget(vDato,'SamplingInstants'); sa = sa{expnr};
            else
                strdomaintype = 'frequency';
            end
            if flag
                msg = sprintf(['The %s span specified ',...
                    'for computing the model fit cannot be evaluated. ',...
                    'Please check the text you typed in the Options dialog box.'], strdomaintype);
                errordlg(msg,'Error Dialog','modal');
                
                opt(3,1) = ' '; set(Opthand,'UserData',opt); set(XID.opt(3,1),'string','Default');
                if idIsValidHandle(wb), close(wb), end
                return
            end
            
            sumsamp = sort(sumsamp);
            if isempty(sumsamp)
                sumsamp = 1:length(gc);
            else
                if dom=='t'
                    
                    %{
                    sumsamp = 1+((sumsamp(1)-t0)/TSamp:(sumsamp(length(sumsamp))-t0)/TSamp);
                    indss = sumsamp<=length(gc) & sumsamp>0;
                    sumsamp = round(sumsamp(indss));
                    %}
                    sumsamp = find(sa>=sumsamp(1) & sa<=sumsamp(end));
                else
                    freqVector = vDato.Frequency;
                    sumsamp = find(freqVector>=sumsamp(1) & freqVector<=sumsamp(end));
                end
            end
            
            if isempty(sumsamp)
                errordlg(['The specified range does not overlap with the ',strdomaintype,...
                    ' span of the validation data. Default value (whole range) will be used.'],...
                    'Error Dialog','modal');
                opt(3,1) = ' '; set(Opthand,'UserData',opt); set(XID.opt(3,1),'string','Default');
                sumsamp = 1:length(gc);
            elseif isscalar(sumsamp)
                errordlg('The specified span must contain at least two samples of the validation data.',...
                    'Error Dialog', 'modal')
                opt(3,1) = ' '; set(Opthand,'UserData',opt); set(XID.opt(3,1),'string','Default');
                sumsamp = 1:length(gc);
            end
         yval = yval(sumsamp);   
        end % if models==0
        Lm_ = length(models);
        
        for k=models
            if idIsValidHandle(wb), waitbar(k/Lm_,wb), end
            if k>0
                %yval = yval(sumsamp);
                khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
                kstr=findobj(khax,'tag','name');
                klin=findobj(khax,'tag','modelline');
                [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
                %u_ind=[];y_ind=[];stopflag=0;
                
                docalc = 1;
                doplot = 0;
                if dom=='f'
                    if nu == 0
                        errordlg(['Model output plots are not supported for frequency ',...
                            'domain data with no input.'],'Error Dialog','Modal');
                        docalc = 0;
                    elseif ~isinf(PH)
                        errordlg(['Prediction is not a possible choice for ',...
                            'frequency domain data.'],'Error Dialog','Modal');
                        docalc = 0;
                    elseif isa(model,'idnlmodel')
                        iduistat('No model output for nonlinear models when using frequency domain data.',0,Figno);
                        docalc = 0;
                    end
                end
                if ~(isa(model,'idmodel')||isa(model,'idnlmodel')) %||isaimp(model)
                    iduistat('No model output for SPA models.',0,Figno);
                    docalc = 0;
                end
                if docalc
                    ynam = pvget(model,'OutputName');
                    yna = pvget(vDato,'OutputName');
                    unam = pvget(model,'InputName');
                    una = pvget(vDato,'InputName');
                    yni = setxor(ynam, yna);
                    uni = setxor(unam, una);
                    if (~isempty(yni) || ~isempty(uni))
                        iduistat('Some channels in the validation data are missing.',0,Figno)
                    end
                    try
                        CompData = getexp(vDato,expnr);
                        if CompData.Ts==0 && model.Ts~=0
                            try
                                model = d2c(model);
                            catch Ed2c
                                errordlg({'Model could not be transformed into continuous-time for computing the response.',...
                                    'Export the model to Workspace, transform using D2C command and import the transformed model back into the model board of the GUI.'},...
                                    'Error Dialog','modal')
                                %if idIsValidHandle(wb), close(wb), end
                                %return
                                continue;
                            end
                        end
                        [yp,fit] = compare(CompData,model,PH,'samples',sumsamp);
                        if ~isempty(yp{1}),
                            yp{1} = yp{1}(sumsamp);
                        end
                    catch E
                        errordlg(E.message,'Error Dialog','modal')
                        %if idIsValidHandle(wb), close(wb), end
                        %yp = {[]}; doplot = 0; 
                        figure(XIDplotw(Figno,1))
                        continue;
                        %return
                    end
                    
                    yyp = yp{1};
                    if ~isempty(yyp)
                        nry = find(strcmp(pvget(yyp,'OutputName'),kydes));
                    else
                        nry = [];
                    end
                    if isempty(nry)
                        errordlg(...
                            ['The model ',name,' requires input/output channels ',...
                            'that are not available in the validation data.'],'Error Dialog','modal');
                        
                        figure(XIDplotw(Figno,1))
                        %if idIsValidHandle(wb), close(wb), end
                        continue
                    else
                        gc = yp{1}.y(:,nry);
                        doplot = 1;
                        fit = fit(1,1,nry);
                    end
                end
                isconf = 0;
                if isa(model,'idmodel')
                    try
                        [~,sdgc] = sim(getexp(vDato,expnr),model);
                    catch
                        %continue;
                        sdgc = [];
                    end
                    if ~isempty(sdgc)
                        isconf = 1;
                        sdgc = sdgc.y(:,ky);
                        sdgc = sdgc(sumsamp);
                    end
                end
                
                xusd1 = get(xax(1),'UserData');set(xax(1),'userdata',[]);
                if strcmp(get(hsd,'checked'),'on')
                    onoff = 'on';
                else
                    onoff = 'off';
                end
            else % i.e. if k==0
                doplot=1;
            end % if k>0
            if doplot
                xaxtab=findobj(XIDplotw(3,1),'tag','table');
                if k>0
                    [~,cgc] = size(gc);
                    if isdiff
                        gc = yval-gc;
                    end
                    color=get(klin,'color');
                    if dom=='f'
                        TImeC = pvget(vDato,'SamplingInstants');
                        TImeC = TImeC{expnr};
                        TImeC = TImeC(sumsamp);
                    else
                        TImeC = repmat(sa(sumsamp),1,cgc); %(0:rgc-1)*TSamp+t0;
                        %TImeC = TImeC*ones(1,cgc);
                    end
                    %TImeC = TImeC(sumsamp);
                    axes(xax(1))
                    if dom=='f'
                        if hz
                            TImeC=TImeC/2/pi;
                            %xlab = 'Hz';
                        else
                            %xlab = 'rad/s';
                        end
                        if plx, set(xax(1),'Xscale','log'),else set(xax(1),'Xscale','linear'),end
                        if ply, set(xax(1),'Yscale','log'),else set(xax(1),'Yscale','linear'),end
                    end
                    if isreal(gc)
                        ydat = gc;
                    else
                        ydat = abs(gc);
                    end
                    xusd1(2*k+1,1)=line(TImeC,ydat,'color',color,...
                        'userdata',kstr,'parent',xax(1));
                    axes(xaxtab);
                    fz=idlayout('fonts',100);
                    xusd1(2*k+1,2)=text(0,0,...
                        [get(kstr,'string'),': ',num2str(fit,4)],'color',color,...
                        'units','points','HorizontalAlignment','left',...
                        'userdata',fit,'tag','fits','fontsize',fz,'parent',xaxtab);
                end % if k>0
                axes(xaxtab);
                fits=findobj(xaxtab,'tag','fits');
                vals=[];
                for kf=fits'
                    vals=[vals,get(kf,'userdata')];
                end
                [~,indv]=sort(-vals);
                kp=15;
                xlead=findobj(xaxtab,'tag','leader');
                set(xlead,'units','points');xlpos=get(xlead,'pos');
                set(xlead,'units','norm');
                invindv=indv(:)';
                for kf=invindv
                    set(fits(kf),'pos',[1 xlpos(2)-kp]);
                    kp=kp+15;
                end
                if k==0,
                    iduistat('',0,3);
                    if idIsValidHandle(wb), close(wb), end
                    return
                end
                % k=0 has just been a response to resizing.
                hnr = xusd1(2*k+1,1:2);
                axes(xax(1))
                if ISSim
                    if isconf
                        xusd1(2*k+2,1:2)=line([TImeC TImeC],[gc+SD*sdgc gc-SD*sdgc],...
                            'color',color,'linestyle','-.',...
                            'Visible',onoff,'userdata',kstr,'tag','conf','parent',xax(1))';
                        hnr=[hnr,xusd1(2*k+2,1:2)];
                    else
                        xusd1(2*k+2,1:2)=[-1,-1];
                    end
                end
                if xusd1(2,2)==0 && ~isdiff
                    if isreal(vDat(:,dky))
                        ydat = vDat(:,dky);
                    else
                        ydat = abs(vDat(:,dky));
                    end
                    ydat = ydat(sumsamp);
                    xusd1(2,2)=line(TImeC,ydat,'color',textcolor,...
                        'userdata',kv(3),'parent',xax(1));
                end
                usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                set(khax,'userdata',usd);
            else
                xusd1(2*k+1,1)=-1;
            end % end doplot
            set(xax(1),'UserData',xusd1)
        end %for models
        if exist('xusd1','var') && size(xusd1,2)>1 && idIsValidHandle(xusd1(2,2)) && xusd1(2,2)~=0
            uistack(xusd1(2,2),'bottom') %bring data curve beneath all others
        end
        
        if newplot,axis(axis),axis('auto'),end
        if idIsValidHandle(wb), close(wb), end
        
    elseif Figno==4  % ZPPLOT
        iduistat('Computing Poles and Zeros...')
        axes(xax(1))
        
        newc=findobj(xax(1),'tag','zpucl');
        om = 2*pi*(0:100)/100;
        w = exp(om*sqrt(-1));
        if isempty(newc)
            
            huc = line(real(w),imag(w),'color',textcolor,'vis','off','tag','zpucl');
            ucmen = findobj(XIDplotw(4,1),'tag','zpuc');
            if ~isempty(ucmen)
                if strcmp(get(ucmen,'checked'),'on')
                    set(huc,'vis','on');
                end
            end
            hreiem(1) = line([-1 1],[0 0],'color',textcolor,'vis','off','tag','zpaxr','parent',xax(1));
            hreiem(2) = line([0 0],[-1 1],'color',textcolor,'vis','off','tag','zpaxi','parent',xax(1));
            ucmen = findobj(XIDplotw(4,1),'tag','zpax');
            if ~isempty(ucmen)
                if strcmp(get(ucmen,'checked'),'on')
                    set(hreim,'vis','on');
                end
            end
            axis('square'),%set(XIDmen(4,15),'checked','on'); %%LL
        end
        
        for kcount=models
            khax=findobj(modaxs,'flat','tag',['model',int2str(kcount)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            doplot=1;docalc=1;
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            if isa(model,'idnlhw')
                docalc=0;doplot=0;
                %model = getlinmod(model);
                iduistat('No plot for IDNLHW models.',0,Figno);
            elseif isa(model,'idnlarx')
                docalc=0;doplot=0;
                iduistat('No plot for IDNLARX models.',0,Figno);
            elseif isa(model,'idnlgrey')
                docalc=0;doplot=0;
                iduistat('No plot for IDNLGREY models.',0,Figno);
            end
            if isempty(ky)||isempty(ku)
                iduistat(chmess,0,Figno);
                docalc=0;doplot=0;  figure(XIDplotw(Figno,1)),
                
            end
            if docalc
                if isa(model,'idfrd')||isaimp(model)
                    doplot=0;
                    iduistat('No plot for CRA and SPA models.',0,Figno);
                else
                    doplot=1;
                    %zepo=iduicalc('zp',model,ky,ku);
                end
            end %if docalc
            
            xusd=get(xax(1),'UserData');set(xax(1),'UserData',[]);
            [nrxusd,ncxusd]=size(xusd);
            if doplot
                if ku>0
                    [zz,pp,k,zzsd,ppsd]=zpkdata(model);
                else
                    [zz,pp,k,zzsd,ppsd]=zpkdata(model('n'));
                end
                if ku>0
                    kup = ku;
                else
                    kup = -ku;
                end
                zz = zz{ky,kup};
                pp = pp{ky,kup};
                if isempty(zzsd) && isempty(ppsd),isconf=0;else isconf=1;end
                if isconf
                    zzsd = zzsd{ky,kup};
                    ppsd = ppsd{ky,kup};
                end
                
                %getzp(zepo,ku,ky);
                color=get(klin,'color');
                MATLABversion = version;
                if MATLABversion(1)=='4',
                    PropertyName = 'LineStyle';
                else
                    PropertyName = 'Marker';
                end
                sl1 = line(real(zz),imag(zz),...
                    'color',color,PropertyName,'o','userdata',kstr,'parent',xax(1));
                sl2 = line(real(pp),imag(pp),...
                    'color',color,PropertyName,'x','userdata',kstr,'parent',xax(1));
                if MATLABversion(1)~='4',
                    set(sl1,'Linestyle','none');
                    set(sl2,'Linestyle','none');
                end
                % Now follows the confidence regions
                
                sl3=[];sl4=[];nc=[];
                if isempty(zzsd)
                    %zeros_cf=0;
                else
                    %zeros_cf=1;
                    %zepo=[zz,zzsd];[nrll,nc]=size(zepo);
                    for k=1:size(zz,1)
                        %sl31 = [];
                        z = zz(k,:); dz = zzsd(:,:,k);
                        if imag(z)==0
                            rp=real(z+SD*sqrt(dz(1,1))*[-1 1]);
                            [mr,nr] = size(rp);
                            sl31 = line(rp,zeros(mr,nr),'color',color,'linestyle','-',...
                                'visible','off','userdata',kstr,'parent',xax(1));
                        else
                            [V,D]=eig(dz); z1=real(w)*SD*sqrt(D(1,1));
                            z2=imag(w)*SD*sqrt(D(2,2)); X=V*[z1;z2];
                            if imag(z)<0,X(2,:)=-X(2,:);end
                            
                            X=[X(1,:)+real(z);X(2,:)+imag(z)];
                            sl31 = line(X(1,:),X(2,:),'color',color,...
                                'linestyle','-','visible','off'...
                                ,'userdata',kstr,'parent',xax(1));
                            sl = line(X(1,:),-X(2,:),'color',color,...
                                'linestyle','-','visible','off'...
                                ,'userdata',kstr,'parent',xax(1));
                            
                            sl31=[sl31;sl];
                        end
                        sl3=[sl3;sl31];
                        
                    end  %for k=
                end % if isempty(zzsd)
                
                if isempty(ppsd)
                    %poles_cf=0;
                else
                    %poles_cf=1;
                    %zepo=[pp,ppsd];[nrll,nc]=size(zepo);
                    for k=1:size(pp,1)
                        %sl41 = [];
                        z = pp(k,:); dz = ppsd(:,:,k);
                        if imag(z)==0
                            rp=real(z+SD*sqrt(dz(1,1))*[-1 1]);
                            [mr,nr] = size(rp);
                            sl41 = line(rp,zeros(mr,nr),'color',color,'linestyle','-',...
                                'visible','off','userdata',kstr,'parent',xax(1));
                        else
                            [V,D]=eig(dz); z1=real(w)*SD*sqrt(D(1,1));
                            z2=imag(w)*SD*sqrt(D(2,2)); X=V*[z1;z2];
                            if imag(z)<0,X(2,:)=-X(2,:);end
                            
                            X=[X(1,:)+real(z);X(2,:)+imag(z)];
                            sl41 = line(X(1,:),X(2,:),'color',color,...
                                'linestyle','-','visible','off'...
                                ,'userdata',kstr,'parent',xax(1));
                            sl=line(X(1,:),-X(2,:),'color',color,...
                                'linestyle','-','visible','off'...
                                ,'userdata',kstr,'parent',xax(1));
                            
                            sl41=[sl41;sl];
                        end
                        sl4=[sl4;sl41];
                        
                    end  %for k=
                end % if isempty(ppsd)
                l1=length(sl1)+length(sl2);l2=length(sl3)+length(sl4);
                if ncxusd<l1+l2+2,xusd=[xusd,zeros(nrxusd,l1+l2+2-nc)];end
                if l1>0,xusd(2*kcount+1,1:l1)=[sl1' sl2'];hnr=[sl1',sl2'];end
                if l2>0,
                    xusd(2*kcount+2,1:l2)=[sl3',sl4'];hnr=[hnr,sl3',sl4'];
                else
                    xusd(2*kcount+2,1)=-1;
                end
                if strcmp(get(hsd,'checked'),'on')
                    set(idnonzer([sl3',sl4']),'visible','on');
                end
            else
                xusd(2*kcount+1,1)=-1;
            end  %if doplot
            set(xax(1),'Userdata',xusd)
            usd=[idnonzer(get(khax,'userdata'));hnr(:)];
            set(khax,'userdata',usd);
            
        end %for kcount
        hre=findobj(XIDplotw(4,1),'tag','zpaxr');
        set(hre,'xdata',get(get(hre,'parent'),'xlim'));
        him=findobj(XIDplotw(4,1),'tag','zpaxi');
        set(him,'ydata',get(get(hre,'parent'),'ylim'));
    elseif Figno==5  % This is transient response
        iduistat('Computing transient response...')
        wb = waitbar(0,'Computing transient response...');
        TImespan=eval(deblank(opt(2,:)));
        if TImespan == 0
            TImespan = [];
        end
        %if isempty(TImespan),TImespan=1:40;end
        if eval(opt(3,:))==1,ISStep=1;else ISStep=0;end
        if eval(opt(1,:))==2,ISStem=1;else ISStem=0;end
        ulev = [eval(opt(4,:));eval(opt(5,:))];
        
        Lm_ = length(models);
        for k=models
            if idIsValidHandle(wb), waitbar(k/Lm_,wb), end
            % khax can be multi-valued if model is moved around in trash and multiple boards; hence added ('vis', 'on') check(r.s.)
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)],'vis','on');
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            doplot=1;docalc=1;
            if isempty(ky)||isempty(ku)
                iduistat(chmess,0,Figno);
                docalc=0;doplot=0;
                figure(XIDplotw(Figno,1)),
                
            end
            if ku<0 %noise channel POSSIBLY special treatment of idnlmodel
                if isa(model,'idnlmodel')
                    iduistat('No noise response for nonlinear models.',0,Figno);
                    docalc = 0; doplot = 0;
                else
                    model = model('n');
                    ku = abs(ku);
                end
            end
            if docalc
                if isempty(model)
                    iduistat('No response generated for empty models.',0,Figno);
                    doplot=0;
                else
                    %% First do the step for all models
                    if ISStep
                        if isa(model,'idfrd')
                            iduistat('No transient response for SPA model.',0,Figno);
                            doplot=0;
                        else
                            [IR,TImeS,sdIR] = step(model,TImespan,'ulev',ulev);
                            if isempty(sdIR)
                                isconf = 0;
                            else
                                isconf = 1;
                            end
                            %if ndims(IR)==3
                            IR = squeeze(IR(:,ky,ku));
                            if ~isempty(sdIR)
                                sdIR = squeeze(sdIR(:,ky,ku));
                            end
                            %end
                        end
                    elseif isa(model,'idnlmodel')
                        iduistat('No impulse response for nonlinear model.',0,Figno);
                        doplot = 0;
                    elseif isa(model,'idfrd')
                        iduistat('No transient response for SPA model.',0,Figno);
                        doplot=0;
                    else
                        % Impulse response
                        [IR,TImeS,sdIR] = impulse(model,TImespan);
                        if isempty(sdIR)
                            isconf = 0;
                        else
                            isconf = 1;
                        end
                        %if ndims(IR)==3
                        IR = squeeze(IR(:,ky,ku));
                        if ~isempty(sdIR)
                            sdIR = squeeze(sdIR(:,ky,ku));
                        end
                        %end
                    end
                end %isempty(model)
                
            end % if docalc
            xusd=get(xax(1),'userdata');set(xax(1),'UserData',[]);
            if doplot
                color=get(klin,'color');
                if strcmp(get(hsd,'checked'),'on')
                    onoff='on';
                else
                    onoff='off';
                end
                axes(xax(1))
                if ISStem
                    xx=[TImeS';TImeS';nan*ones(size(TImeS'))];
                    yy=[zeros(1,length(TImeS));IR';nan*ones(size(IR'))];
                    MATLABversion = version;
                    if MATLABversion(1)=='4',
                        PropertyName = 'LineStyle';
                    else
                        PropertyName = 'Marker';
                    end
                    
                    sl1=line(TImeS',IR','color',color,...
                        PropertyName,'o','userdata',kstr,'parent',xax(1));
                    
                    sl2=line(xx(:),yy(:),'color',color,...
                        'userdata',kstr,'parent',xax(1));
                    set(sl1,'Linestyle','none');
                    xusd(2*k+1,1:2)=[sl1' sl2'];hnr=[sl1',sl2'];
                    
                else
                    xusd(2*k+1,1)=line(TImeS,IR,'color',color,...
                        'userdata',kstr,'parent',xax(1));
                    hnr=xusd(2*k+1,1);
                end
                if isconf
                    if ISStem && ~ISStep
                        curves=[SD*sdIR -SD*sdIR];
                    else
                        curves=[IR+SD*sdIR  IR-SD*sdIR];
                    end
                    xusd(2*k+2,1:2)=line([TImeS TImeS],curves,'color',color,...
                        'linestyle','-.','visible',onoff,'userdata',kstr,...
                        'tag','conf','parent',xax(1))';
                    hnr=[hnr,xusd(2*k+2,1:2)];
                else %noconf
                    xusd(2*k+2,1:2)=[-1,-1];
                end
            else
                xusd(2*k+1,1)=-1;
            end
            set(xax(1),'Userdata',xusd)
            usd=[idnonzer(get(khax,'userdata'));hnr(:)];
            set(khax,'userdata',usd);
            if newplot, axis(axis),axis('auto'),end
        end %for k=
        if idIsValidHandle(wb), close(wb), end
        
    elseif Figno==6
        iduistat('Computing residuals...')
        wb = waitbar(0,'Computing residuals...');
        maxsize=idmsize;
        try
            [z,z_info,vDat_name]=iduigetd('v');
            if isa(z,'idfrd')
                z = iddata(z,'me');
                idfrdflag = 1;
            else
                idfrdflag = 0;
            end
        catch
            errordlg(['A Validation Data set must be' ...
                ' supplied'],'Error Dialog','modal')
            if idIsValidHandle(wb), close(wb), end
            return
        end
        M=eval(opt);if isempty(opt),M=21;else M=M+1;end
        [N,dny,dnu]=size(z);
        ynad = pvget(z,'OutputName');
        unad = pvget(z,'InputName');
        dky = find(strcmp(ynad,kydes));
        dku = find(strcmp(unad,kudes));
        if isempty(dky)
            errordlg(['The validation data ',vDat_name,' does not contain ',...
                'the chosen output channel for the residual plot.'],'Error Dialog','modal');
            %docalc=0;doplot=0;
            if idIsValidHandle(wb), close(wb), end
            return
        end
        Lm_ = length(models);
        for k=models
            if idIsValidHandle(wb), waitbar(k/Lm_,wb); end
            khax=findobj(modaxs,'flat','tag',['model',int2str(k)]);
            kstr=findobj(khax,'tag','name');
            klin=findobj(khax,'tag','modelline');
            [model,ny,nu,ky,ku,yna,una,name] = getchan(klin,kydes,kudes);
            docalc = 1; %doplot = 1;
            if isa(model,'idnlmodel')&&strcmp(pvget(z,'Domain'),'Frequency')
                docalc = 0;%doplot = 0;
                iduistat('No residuals for nonlinear models and frequency domain data.',0,Figno);
            end
            
            if isa(model,'idfrd')||isaimp(model)
                iduistat('No plot for CRA and SPA models.',0,Figno);
                docalc=0;%doplot=0;
            end
            if isa(z,'iddata')&&any(cell2mat(pvget(z,'Ts'))==0)
                iduistat('No residuals for Continuous Time Data.',0,Figno)
                docalc = 0; %doplot = 0;
            end
            if docalc
                
                u_ind=[];y_ind=[];stopflag=0;
                for kku=1:length(una)
                    kuindex = find(strcmp(una{kku},unad));
                    if isempty(kuindex)
                        stopflag=1;
                    else
                        u_ind=[u_ind,kuindex];
                    end
                end
                for kky=1:length(yna)
                    kyindex = find(strcmp(yna{kky},ynad));
                    if isempty(kyindex)
                        stopflag=1;
                    else
                        y_ind=[y_ind,kyindex];
                    end
                end
                
                if stopflag
                    errordlg(...
                        ['The model ',name,' requires input/output channels ',...
                        'for the residual plot that are not available ',...
                        'in the validation data.'],'Error Dialog','modal');
                    doplot=0;  figure(XIDplotw(Figno,1)),
                elseif isempty(ky)
                    iduistat(chmess2,0,Figno);
                    doplot=0;  figure(XIDplotw(Figno,1)),
                else
                    doplot=1;
                end
                if doplot
                    was1 = ctrlMsgUtils.SuspendWarnings;
                    % First remove 0 freq if integrators are present
                    if strcmpi(pvget(z,'Domain'),'frequency')
                        fre=pvget(z,'SamplingInstants');
                        zfflag = 0;
                        for kexp = 1:length(fre)
                            if any(fre{kexp}==0)
                                zfflag = 1;
                            end
                        end
                        if zfflag
                            fr = freqresp(model,0);
                            if any(~isfinite(fr(:)))
                                z = rmzero(z);
                            end
                        end
                    end
                    e = pe(z(:,y_ind,u_ind),model);
                    
                    delete(was1)
                    pos = idlayout('axes',1);posy = pos(1,:);
                    posyts = idlayout('axes',7);
                    if nu>0
                        set(xax(1),'pos',posy,'xticklabel',[]);
                    else
                        set(xax(1),'pos',posyts,'xticklabelmode','auto');
                        axes(xax(2)),cla,
                        set(xax(2),'vis','off')
                    end
                    xusd1=get(xax(1),'userdata');set(xax(1),'userdata',[]);
                    color=get(klin,'color');
                    ee = [e,z(:,[],u_ind)];
                    dom = pvget(ee,'Domain'); dom = lower(dom(1));
                    if dom=='t'
                        r=covf(ee(:,ky,ku),M,maxsize); %#ok<FNDSB>
                        
                        nr=1:M-1;
                        ind=1;
                        sdre=SD*(r(ind,1))/sqrt(sum(N))*ones(2*M-1,1);
                        
                        axes(xax(1));[nllr,nllc]=size(r);
                        xusd1(2*k+1,1)=line(nr,r(ind,2:nllc)'/r(ind,1),'color',color,...
                            'userdata',kstr,'parent',xax(1));
                        xusd1(2*k+1,2)=line(-nr,r(ind,2:nllc)'/r(ind,1),'color',color,...
                            'userdata',kstr,'parent',xax(1));
                        
                        xusd1(2*k+2,1:2)=line(-M+1:M-1,[sdre -sdre]/r(ind,1),'color',color,...
                            'linestyle',':','Visible','off',...
                            'tag','conf','userdata',kstr,'parent',xax(1))';
                        hnr=[xusd1(2*k+1,1:2),xusd1(2*k+2,1:2)];
                        if newplot,axis(axis),axis('auto'),end
                        if nu>0 && ~isempty(ku)
                            nr=-M+1:M-1;
                            set(xax(2),'vis','on')
                            ind1=3;ind2=2;indy=1;indu=4;
                            sdreu=SD*sqrt(r(indy,1)*r(indu,1)+2*(r(indy,2:M)*r(indu,2:M)'))...
                                /sqrt(sum(N))*ones(2*M-1,1);
                            axes(xax(2))
                            xusd2=get(xax(2),'userdata');set(xax(2),'userdata',[]);
                            xusd2(2*k+1,1)=line(nr,...
                                [r(ind1,M:-1:1) r(ind2,2:M) ]'/(sqrt(r(indy,1)*r(indu,1))),...
                                'color',color,'userdata',kstr,'parent',xax(2));
                            
                            xusd2(2*k+2,1:2)=line(nr,[sdreu -sdreu]/(sqrt(r(indy,1)*r(indu,1))),...
                                'LineStyle',':','Visible','off','color',color...
                                ,'userdata',kstr,'tag','conf','parent',xax(2))';
                            if newplot,axis(axis),axis('auto')
                            end
                            set(xax(2),'userdata',xusd2)
                            hnr=[hnr,xusd2(2*k+1,1),xusd2(2*k+2,1:2)];
                        end %if nu>0
                    else % FD calculations
                        my = arx(ee(:,dky,[]),M,'ini','z');
                        [magy,~,w,dmagy] = boderesp(my);
                        magy = squeeze(magy);
                        dmagy = squeeze(dmagy);
                        axes(xax(1));
                        
                        xusd1(2*k+1,1)=line(w,magy,'color',color,...
                            'userdata',kstr,'parent',xax(1));
                        
                        xusd1(2*k+2,1)=line(w,magy+SD*dmagy,'color',color,...
                            'linestyle',':','Visible','off',...
                            'tag','conf','userdata',kstr,'parent',xax(1))';
                        xusd1(2*k+2,2)=line(w,max(magy-SD*dmagy,0),'color',color,...
                            'linestyle',':','Visible','off',...
                            'tag','conf','userdata',kstr,'parent',xax(1))';
                        hnr=[xusd1(2*k+1,1:2),xusd1(2*k+2,1:2)];
                        if newplot,axis(axis),axis('auto'),end
                        
                        if nu>0 && ~isempty(ku)
                            if idfrdflag
                                ini = 'z';
                            else
                                ini = 'a';
                            end
                            m = arx(ee(:,dky,:),[ 0 M*ones(1,nu) zeros(1,nu)],'ini',ini);
                            [mag,~,w,dmag] = boderesp(m);
                            mag=squeeze(mag(1,ku,:));
                            dmag=squeeze(dmag(1,ku,:));
                            set(xax(2),'vis','on')
                            axes(xax(2))
                            xusd2=get(xax(2),'userdata');set(xax(2),'userdata',[]);
                            xusd2(2*k+1,1)=line(w,mag,...
                                'color',color,'userdata',kstr,'parent',xax(2));
                            
                            xusd2(2*k+2,1)=line(w,mag+SD*dmag,...
                                'LineStyle',':','Visible','off','color',color,...
                                'userdata',kstr,'tag','conf','parent',xax(2))';
                            
                            xusd2(2*k+2,2)=line(w,max(mag-SD*dmag,0),...
                                'LineStyle',':','Visible','off','color',color...
                                ,'userdata',kstr,'tag','conf','parent',xax(2))';
                            if newplot,
                                axis(axis),axis('auto')
                            end
                            set(xax(2),'userdata',xusd2)
                            hnr=[hnr,xusd2(2*k+1,1),xusd2(2*k+2,1:2)];
                        end %if nu>0
                        
                    end
                    if strcmp(get(hsd,'checked'),'on')
                        set(idnonzer(xusd1(2*k+2,1:2)),'Visible','on')
                        if nu >0
                            try
                                set(idnonzer(xusd2(2*k+2,1:2)),'Visible','on')
                            end
                        end
                    end
                    
                    usd=[idnonzer(get(khax,'userdata'));hnr(:)];
                    set(khax,'userdata',usd);
                else
                    xusd1(2*k+1,1)=-1;
                end  % if doplot
                set(xax(1),'Userdata',xusd1)
            end % if docalc
        end %for k=models
        if idIsValidHandle(wb), close(wb), end
        iduital(6);
        
    end %if Figno
    
    
end % for figures
lw1 = lastwarn;
if ~isempty(lw1)
    idgwarn(lw1)
end

% if ~isempty(lastwarn)&warflag
%     mess = '(Warning Dialogs can be turned off under the Options Menu in the main window)';
%     warndlg({lastwarn,mess},'Warning','modal');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,ny,nu,ky,ku,yna,una,mna] =getchan(klin,kydes,kudes)
m = get(klin,'UserData');
%if isa(m,'idmodel')|isa(m,'idfrd')
yna = pvget(m,'OutputName');
una = pvget(m,'InputName');
mna = pvget(m,'Name');

ny = length(yna);
nu = length(una);
ky = find(strcmp(yna,kydes));
ku = find(strcmp(una,kudes));
if isempty(ku) && length(kudes{1})>2
    if strcmp(kudes{1}(1:2),noiprefi('e'))
        kudes = kudes{1}(3:end);
        ku  = find(strcmp(yna,kudes));
        ku = -ku;
    end
end

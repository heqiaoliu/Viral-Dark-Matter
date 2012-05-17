function [amp,phas,w,sdamp,sdphas] = bodeaux(bode,varargin)
%BODEAUX Help function to IDMODEL/BODE and FFPLOT

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.21 $ $Date: 2009/10/16 04:56:32 $

VargLen = length(varargin);
if nargout
    err = 0;
    if VargLen>2
        ctrlMsgUtils.error('Ident:analysis:RequiresSingleModelWithOutputArgs','bode')
    elseif VargLen==2 && (~isa(varargin{2},'double'))
        if iscell(varargin{2}) % Frequency information
            wf = varargin{2};
            if length(wf)>2
                nopo = wf{3};
            else
                nopo = 100;
            end
            
            if wf{1}<=0
                if wf{2}<=0
                    ctrlMsgUtils.error('Ident:analysis:freqrespInvalidFreq')
                end
                ctrlMsgUtils.warning('Ident:analysis:freqrespInvalidFreq2')
                wf{1} = wf{2}/1000;
            end
            varargin{2} = logspace(log10(wf{1}),log10(wf{2}),nopo);
        else%end if cell
            err = 1;
        end
    end
    if err
        if bode
            command = 'bode';
            hlp = 'idmodel/bode';
        else
            command = 'ffplot';
            hlp = command;
        end
        ctrlMsgUtils.error('Ident:analysis:freqrespCallingSyntax',command,hlp);
    end
    if VargLen==2 && ~bode
        varargin{2}=varargin{2}*2*pi;
    end
    if nargout<4
        [amp,phas,w] = boderesp(varargin{:});
    else
        [amp,phas,w,sdamp,sdphas] = boderesp(varargin{:});
    end
    return
end

residflag = 0;
if nargin>1 && ischar(varargin{end}) && strcmpi(varargin{end},'resid') % special call from resid
    residflag = 1;
    varargin = varargin(1:end-1);
end
[sys,sysname,PlotStyle,sd,ap,om,mode,fillsd] = sysardec(bode,varargin{:});
if isempty(sys),return,end

clf
%newplot
% Sort out frequency labels
tu = 's';
for k = 1:length(sys)
    if isa(sys{k},'idmodel')
        tu = pvget(sys{k},'TimeUnit');
        if isempty(tu), tu = 's'; end
        if bode
            uni = ['rad/',tu];
        else
            uni = ['1/',tu];
        end
    elseif isa(sys{k},'idfrd')
        uni = pvget(sys{k},'Units');
        if strcmp(uni,'Hz')
            if bode
                uni = 'rad/s';
            end
        elseif strncmpi(uni,'r',1)
            if ~bode
                uni = ['1/',uni(findstr(uni,'/')+1:end)];
            end
        elseif any(lower(uni(1))==['1','c'])
            if bode
                uni = ['rad/',uni(findstr(uni,'/')+1:end)];
            end
        end
    end
    if k==1
        uni1=uni;
    end
    if ~strcmp(uni,uni1) && ~isempty(tu)
        ctrlMsgUtils.warning('Ident:plots:modelFreqUnitsMismatch')
    end
end
uni = uni1;

if ~bode
    om = om*2*pi; % check this: om is returned in Hz if not bode
end
if any(om<0)
    %warning('Negative frequencies ignored.')
    om = om(om>=0);
end


[ynared,unared,yind,uind] = idnamede(sys);
sd1 = sd;
if size(uind,2)==1
    tsu = uind;
elseif isempty(uind)
    tsu = 0;
else
    tsu = sum(uind');
end
if any(tsu==0) % Then spectra will be plotted
    spplot=1;
else
    spplot=0;
end
if strcmp(mode,'sep')
    titleadd=[];
else
    titleadd = 'Last plotted: ';
end
cols=get(gca,'colororder');
if sum(cols(1,:))>1.5
    colord=['y','m','c','r','g','w','b']; % Dark background
else
    colord=['b','g','r','c','m','y','k']; % Light background
end

for ks = 1:length(sys)
    sys1 = sys{ks};
    Ts = pvget(sys1,'Ts');
    omm = om;
    if Ts>0
        omm = om(om<pi/Ts); % never exceed the Nyquist frequency;
    end
    if isa(sys1,'idfrd')
        omm = [min(omm),max(omm)];
    end
    if sd
        if(isa(sys1,'idmodel')&&~isa(sys1,'idpoly'))
            [thbbmod,sys1,flag] = idpolget(sys1);
            if flag
                try
                    assignin('caller',sysname{ks},sys1)
                catch
                end
            end
            if isempty(thbbmod)
                sys1=pvset(sys1,'CovarianceMatrix','None');
            end
        end
        [mag,phas,w,sdamp,sdphas] = boderesp(sys1,omm);
        Mag{ks}=mag;Phas{ks}=phas;W{ks}=w;
        Sdamp{ks}=sdamp;Sdphas{ks}=sdphas;
    else
        [mag,phas,w] = boderesp(sys1,omm);
        Mag{ks}=mag;Phas{ks}=phas;W{ks}=w;
    end
end
for yna = 1:length(ynared)
    for una = 1:length(unared)
        maxw = -inf; minw = inf;
        maxa = -inf; mina = inf;
        maxp = -inf; minp = inf;
        
        for ks = 1:length(sys)
            if isempty(PlotStyle{ks})
                PStyle=[colord(mod(ks-1,7)+1),'-'];
            else
                PStyle=PlotStyle{ks};
            end
            if fillsd
                fillcol = idutils.getPatchColor(PStyle(1));
            end
            
            if bode
                indbod = find(W{ks}>0);
            else
                indbod = 1:length(W{ks});
            end
            W{ks}=W{ks}(indbod);
            if uind(ks,una)
                if yind(ks,yna) && uind(ks,una)
                    mag = squeeze(Mag{ks}(yind(ks,yna),uind(ks,una),indbod));
                    phas = squeeze(Phas{ks}(yind(ks,yna),uind(ks,una),indbod));
                    maxw = max(maxw,max(W{ks}));
                    minw = min(minw,min(W{ks}));
                    maxa = max(maxa,max(mag));
                    mina = min(mina,min(mag));
                    maxp = max(maxp,max(phas));
                    minp = min(minp,min(phas));
                    
                    if sd
                        if isempty(Sdamp{ks})
                            sd1 = 0;
                        else
                            sdamp = Sdamp{ks}(yind(ks,yna),uind(ks,una),indbod);
                            sdphas = Sdphas{ks}(yind(ks,yna),uind(ks,una),indbod);
                            sd1 = sd;
                        end
                    end
                    if ap=='b'
                        ax = subplot(211);
                        set(ax,'Box','on')
                    else
                        subplot(1,1,1)
                    end
                    
                    %% If we are in the Bode mode initially set the axes
                    %% limits so that the limit picker is not invoked
                    if bode
                        try
                            axis([10^floor(log10(minw)) 10^ceil(log10(maxw)),...
                                10^floor(log10(mina)) 10^ceil(log10(maxa))])
                        end
                    end
                    
                    if ap=='b'|| ap=='a'
                        if bode
                            %% Set the axes scale mode
                            set(gca,'YScale','log')
                            set(gca,'XScale','log')
                            set(gca,'box','on')
                            %% Temporary fix until geck 185713 is fixed
                            LocalPlotData(W{ks},squeeze(mag),PStyle);hold on
                            %  							loglog(W{ks},squeeze(mag),PStyle);hold on
                        else
                            %% Set the axes scale mode
                            set(gca,'YScale','log')
                            set(gca,'XScale','linear')
                            set(gca,'box','on')
                            %% Temporary fix until geck 185713 is fixed
                            LocalPlotData(W{ks}/2/pi,squeeze(mag),PStyle);hold on
                            % 							semilogy(W{ks}/2/pi,squeeze(mag),PStyle); hold on
                        end
                        if ap=='a'
                            xlabel(['Frequency (',uni,')'])
                            %                             if bode
                            %                                 xlabel('Frequency (rad/s)')
                            %                             else
                            %                                 xlabel('Frequency (Hz)')
                            %                             end
                        end
                        
                        ylabel('Amplitude')
                        if sd1
                            %v = axis;
                            if fillsd
                                w = W{ks};
                                amp2 = squeeze(mag); sdamp2 = squeeze(sdamp);
                                xax=[w;w(end:-1:1)];
                                if ~bode
                                    xax = xax/2/pi;
                                end
                                if residflag
                                    bottom = 10^floor(log10(min(amp2)*0.1));
                                    amp2 = zeros(size(amp2));
                                    fillcol = 'y';
                                    edgecol = 'default';
                                else
                                    bottom = realmin; %10^-5;
                                    edgecol = 'none';
                                end
                                yax=[amp2+sd*sdamp2;amp2(end:-1:1)-sd*sdamp2(end:-1:1)];
                                yax=max(yax,bottom);
                                Hp = fill(xax,yax,fillcol,'edgecolor',edgecol);
                                uistack(Hp,'bottom'); set(gca,'Layer','top')
                            else
                                if bode
                                    loglog(W{ks},squeeze(mag)+sd*squeeze(sdamp),[PStyle(1),'-.'])
                                    loglog(W{ks},max(squeeze(mag)-sd*squeeze(sdamp),0),[PStyle(1),'-.'])
                                else
                                    semilogy(W{ks}/2/pi,squeeze(mag)+sd*squeeze(sdamp),[PStyle(1),'-.'])
                                    semilogy(W{ks}/2/pi,max(squeeze(mag)-sd*squeeze(sdamp),0),[PStyle(1),'-.'])
                                end
                                %axis(v)
                            end
                        end
                    end
                    if ap=='b'
                        subplot(212)
                    end
                    if ap=='b'|| ap=='p'
                        if bode
                            semilogx(W{ks},squeeze(phas),PStyle);hold on
                        else
                            plot(W{ks}/2/pi,squeeze(phas),PStyle);hold on
                        end
                        ylabel('Phase (degrees)')
                        xlabel(['Frequency (',uni,')'])
                        %                         if bode
                        %                             xlabel('Frequency (rad/s)')
                        %                         else
                        %                             xlabel('Frequency (Hz)')
                        %                         end
                        if sd1
                            if fillsd
                                w = W{ks};
                                amp2 = squeeze(phas); sdamp2 = squeeze(sdphas);
                                xax=[w;w(end:-1:1)];
                                if ~bode
                                    xax = xax/2/pi;
                                end
                                yax=[amp2+sd*sdamp2;amp2(end:-1:1)-sd*sdamp2(end:-1:1)];
                                %yax=max(yax,10^-5);
                                Hp = fill(xax,yax,fillcol,'edgecolor','none');
                                uistack(Hp,'bottom'); set(gca,'Layer','top')
                            else
                                %   v = axis;
                                if bode
                                    semilogx(W{ks},squeeze(phas)+sd*squeeze(sdphas),[PStyle(1),'-.'])
                                    semilogx(W{ks},squeeze(phas)-sd*squeeze(sdphas),[PStyle(1),'-.'])
                                else
                                    plot(W{ks}/2/pi,squeeze(phas)+sd*squeeze(sdphas),[PStyle(1),'-.'])
                                    plot(W{ks}/2/pi,squeeze(phas)-sd*squeeze(sdphas),[PStyle(1),'-.'])
                                end
                            end
                            %  axis(v)
                        end
                        if bode
                            try
                                axis([10^floor(log10(minw)) 10^ceil(log10(maxw)),...
                                    100*floor(minp/100) 100*ceil(maxp/100)])
                            end
                        end
                    end
                end
            end
        end
        
        if ap=='b'
            subplot(211)
        end
        title([titleadd,'From ',unared{una},' to ',ynared{yna}])
        if ks<length(sys) || yna~=length(ynared) || una~=length(unared) || spplot
            try
                pause
            catch
                hold off
                set(gcf,'NextPlot','replacechildren');
                return
            end
            if strcmp(mode,'sep')
                if ap=='b'
                    subplot(211),cla,hold off
                    subplot(212),cla,hold off
                else
                    subplot(1,1,1),cla,hold off
                end
            end
        end
        
        if strcmp(mode,'sep')
            if ap=='b'
                subplot(211),hold off
                subplot(212),hold off
            else
                subplot(1,1,1),hold off
            end
        end
    end
end
if strcmp(mode,'same')
    if ap=='b'
        subplot(211),hold off
        subplot(212),hold off
    else
        subplot(1,1,1),cla,hold off
    end
end

%% Now for possible spectra
if spplot
    for yna = 1:length(ynared)
        maxw = -inf; minw = inf;
        maxa = -inf; mina = inf;
        for ks = 1:length(sys)
            if isempty(PlotStyle{ks})
                PStyle=[colord(mod(ks-1,7)+1),'-'];
            else
                PStyle=PlotStyle{ks};
            end
            if fillsd
                fillcol = idutils.getPatchColor(PStyle(1));
            end
            
            tsfl = tsflag(sys{ks});
            if ~sum(uind(ks,:))
                if yind(ks,yna)
                    mag = squeeze(Mag{ks}(yind(ks,yna),yind(ks,yna),:));
                    maxw = max(maxw,max(W{ks}));
                    minw = min(minw,min(W{ks}));
                    maxa = max(maxa,max(mag));
                    mina = min(mina,min(mag));
                    if sd
                        if isempty(Sdamp{ks})
                            sd1=0;
                        else
                            sdamp = Sdamp{ks}(yind(ks,yna),yind(ks,yna),:);
                            sd1 = sd;
                        end
                    end
                    subplot(1,1,1),
                    if bode
                        %% Set the axes scale mode
                        set(gca,'YScale','log')
                        set(gca,'XScale','log')
                        %% Temporary fix until geck 185713 is fixed
                        LocalPlotData(W{ks},squeeze(mag),PStyle);hold on
                        %                         loglog(W{ks},squeeze(mag),PStyle);hold on
                    else
                        %% Set the axes scale mode
                        set(gca,'YScale','log')
                        set(gca,'XScale','linear')
                        %% Temporary fix until geck 185713 is fixed
                        LocalPlotData(W{ks}/2/pi,squeeze(mag),PStyle);hold on
                        % 						semilogy(W{ks}/2/pi,squeeze(mag),PStyle);hold on
                    end
                    set(gca,'box','on')
                    xlabel(['Frequency (',uni,')'])
                    %                     if bode
                    %                         xlabel('Frequency (rad/s)')
                    %                     else
                    %                         xlabel('Frequency (Hz)')
                    %                     end
                    ylabel('Power')
                    if sd1
                        if fillsd
                            w = W{ks};
                            amp2 = squeeze(mag); sdamp2 = squeeze(sdamp);
                            xax=[w;w(end:-1:1)];
                            if ~bode
                                xax = xax/2/pi;
                            end
                            yax = [amp2+sd*sdamp2;amp2(end:-1:1)-sd*sdamp2(end:-1:1)];
                            Hp = fill(xax,max(yax,realmin),fillcol,'edgecolor','none');
                            uistack(Hp,'bottom'); set(gca,'Layer','top')
                        else
                            if bode
                                loglog(W{ks},squeeze(mag)+sd*squeeze(sdamp),[PStyle(1),'-.'])
                                loglog(W{ks},max(squeeze(mag)-sd*squeeze(sdamp),0),[PStyle(1),'-.'])
                            else
                                semilogy(W{ks}/2/pi,squeeze(mag)+sd*squeeze(sdamp),[PStyle(1),'-.'])
                                semilogy(W{ks}/2/pi,max(squeeze(mag)-sd*squeeze(sdamp),0),[PStyle(1),'-.'])
                            end
                        end
                        if bode
                            axis([10^floor(log10(minw)) 10^ceil(log10(maxw)),...
                                10^floor(log10(mina)) 10^ceil(log10(maxa))])
                        end
                    end
                end
            end
        end
        if strcmp(tsfl,'NoiseModel')
            texsp = 'Spectrum for disturbance at output ';
        else
            texsp = 'Power spectrum for signal ';
        end
        
        title([titleadd,texsp,ynared{yna}]),
        if ks<length(sys) || yna~=length(ynared)
            try
                pause
            catch
                hold off
                set(gcf,'NextPlot','replacechildren');
                return
            end
            if strcmp(mode,'sep')
                subplot(1,1,1),cla,hold off
            end
            
        end
    end
end
hold off
set(gcf,'NextPlot','replacechildren');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local Functions
%% LocalPlotData: This will add the a line of the proper style to the
%% current axis.
function LocalPlotData(x,y,PStyle)

l = line(x,y);
[L,C,M] = colstyle(PStyle);
if ~isempty(L)
    set(l,'LineStyle',L);
else
    if isempty(M)
        set(l,'LineStyle','-');
    else
        set(l,'LineStyle','none');
    end
end
if ~isempty(C)
    set(l,'Color',C);
end
if ~isempty(M)
    set(l,'Marker',M);
end


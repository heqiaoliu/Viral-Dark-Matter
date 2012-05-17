function [fr,w,covfr] = nyqaux(varargin)
%NYQAUX Help function to NYQUIST.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.7 $ $Date: 2008/10/02 18:51:45 $

[sys,sysname,PlotStyle,sd,ap,om,mode,fill,sdmark,sdstep] = sysardec(3,varargin{:});
if isempty(sys),fr=NaN;w=NaN;covfr=NaN;return,end

if nargout
    if length(sys)>1 
        ctrlMsgUtils.error('Ident:analysis:RequiresSingleModelWithOutputArgs','nyquist')
    elseif nargin>2 || (nargin==2 && isa(varargin{2},'idmodel'))
        ctrlMsgUtils.error('Ident:analysis:freqrespCallingSyntax','nyquist','idmodel/nyquist');
    end
    sys = sys{1};
    if nargout<3
        [fr,w] = freqresp(sys,om);
    else
        [fr,w,covfr] = freqresp(sys,om);
    end
    return
end

if any(om<0)
    ctrlMsgUtils.warning('Ident:analysis:freqrespInvalidFreq3')
    om = om(om>=0);
end

isTs = false(1,length(sys));
for ks = 1:length(sys)
    Nu = size(sys{ks},'Nu');
    if Nu==0
        %warning(['No Nyquist plot for time series model ',sysname{ks},'.'])
        isTs(ks) = true;
    end
end

if any(isTs)
    %{
    sysnameTs = sysname(isTs);
    str1 = '';
    for kk = 1:length(sysnameTs)
        str1 = [str1,',',sysnameTs{kk}];
    end
    %}
    ctrlMsgUtils.warning('Ident:analysis:nyquistTSModel')
    
    if all(isTs)
        % all systems are time series models; no need to proceed
        return
    end
end

sys = sys(~isTs);
sysname = sysname(~isTs);
PlotStyle = PlotStyle(~isTs);

sd1=sd;
[ynared,unared,yind,uind] = idnamede(sys);
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
    titleadd = 'Nyquist Plot ';
else
    titleadd = 'Nyquist Plot. Last plotted: ';
end
om1 = 2.1*pi*(1:100)/100;
ec=exp(om1*sqrt(-1));

for ks = 1:length(sys)
    sys1 = sys{ks};
    %Nu = size(sys1,'Nu');
    if sd
        if(isa(sys1,'idmodel') && ~isa(sys1,'idpoly'))
            [thbbmod,sys1,flag] = idpolget(sys1);
            if flag
                try
                    assignin('caller',sysname{ks},sys1)
                end
            end
            if isempty(thbbmod)
                sys1 = pvset(sys1,'CovarianceMatrix','None');
            end
        end
        
        [fre,w,sdfre] = freqresp(sys1,om);
        Fre{ks} = fre; W{ks} = w;
        Sdfre{ks} = sdfre;
    else
        [fre,w] = freqresp(sys{ks},om);
        Fre{ks} = fre; W{ks} = w;
    end
end

cols = get(gca,'colororder');
if sum(cols(1,:))>1.5
    colord=['y','m','c','r','g','w','b']; % Dark background
else
    colord=['b','g','r','c','m','y','k']; % Light background
end

for yna = 1:length(ynared)
    for una = 1:length(unared)
        for ks = 1:length(sys)
            if isempty(sdstep),sdstep = 10;end
            if isempty(sdmark),sdmark = '*';end
            if isempty(PlotStyle{ks})
                PStyle=[colord(mod(ks-1,7)+1),'-'];
                
            else
                PStyle=PlotStyle{ks};
                if length(PStyle)>3
                    if isnan(str2double(PStyle(4)))
                        nr = 5;
                    else
                        nr = 4;
                    end
                    
                    if nr<=length(PStyle)
                        sdstep = str2double(PStyle(nr:end));
                        sdmark = PStyle(2);
                        PStyle = PStyle([1,3:nr-1]);
                        
                    end
                end
            end
            if uind(ks,una)
                if yind(ks,yna) && uind(ks,una)
                    fre = Fre{ks}(yind(ks,yna),uind(ks,una),:);
                    if sd
                        if isempty(Sdfre{ks})
                            sd1 = 0;
                        else
                            sdfre = Sdfre{ks}(yind(ks,yna),uind(ks,una),:,:,:);
                            sd1 = sd;
                        end
                    end
                    subplot(1,1,1)
                    fre = squeeze(fre);
                    plot(fre,PStyle);hold on
                    ylabel('Imag Axis')
                    xlabel('Real Axis')
                    if sd1
                        for kw = 1:sdstep:length(W{ks})
                            zpsdpl(fre(kw),squeeze(sdfre(:,:,kw,:,:)),...
                                sd,ec,[PStyle(1),sdmark],[PStyle(1),'-'])
                        end
                    end
                end
            end
        end
        
        title([titleadd,'From ',unared{una},' to ',ynared{yna}])
        ax=axis;
        if ax(1)>=0,ax(1)=-abs(ax(2))/10;end
        if ax(2)<=0,ax(2)=abs(ax(1))/10;end
        if ax(3)>=0,ax(3)=-abs(ax(4))/10;end
        if ax(4)<=0,ax(4)=abs(ax(3))/10;end
        axis(ax); ax = axis;
        plot([ax(1) ax(2)],[0 0],'k',[0 0],[ax(3) ax(4)],'k')
        if ks<length(sys) || yna~=length(ynared) || una~=length(unared) || spplot
            try
                pause
            catch
                hold off
                set(gcf,'NextPlot','replacechildren');
                return
            end
            if strcmp(mode,'sep')
                cla,hold off
            end
        end
        if strcmp(mode,'sep')
            hold off
        end
    end
end
if strcmp(mode,'same')
    hold off
end

set(gcf,'NextPlot','replacechildren');

%-------------------------------------------------------------------------
function zpsdpl(z,dz,sd,w,mark1,mark2)
%ZPSDPL Plots standard deviations in zero-pole plots.
%
%   zpsdpl(zepo,sd,w,iz,mark1,mark2)
%
%   This is a help function to zpplot.


if imag(z)==0
    rp=real(z+sd*sqrt(dz(1,1))*[-1 1]);
    [mr,nr] = size(rp);
    plot(rp,zeros(mr,nr),mark1)
else     [V,D]=eig(dz); z1=real(w)*sd*sqrt(max(0,D(1,1)));
    z2=imag(w)*sd*sqrt(max(0,D(2,2))); X=V*[z1;z2];
    if imag(z)<0,X(2,:)=-X(2,:);end
    plot(z,mark1)
    X=[X(1,:)+real(z);X(2,:)+imag(z)];
    plot(X(1,:),X(2,:),mark2)
end

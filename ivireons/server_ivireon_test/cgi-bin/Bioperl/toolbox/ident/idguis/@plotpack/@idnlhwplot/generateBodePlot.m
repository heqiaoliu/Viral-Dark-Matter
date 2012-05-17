function generateBodePlot(this)
% create bode plot of the linear model

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/08/01 12:22:56 $

v = this.Current.LinearComboValue;
unames = this.IONames.u;
ynames = this.IONames.y;
u2 = this.MainPanels(end);

if ~this.isGUI && (v==1)
    % we have multiple inputs/outputs option in combo
    isSinglePlot = false;
else
    isSinglePlot = true;
end

if isSinglePlot
    n = 1;
    [uname,yname] = this.decipherIOPair(v);
    unames = {uname}; ynames = {yname};
    %unames = unames(un); ynames = ynames(yn);
end

L = length(this.ModelData);
mag = cell(1,L);
ph = mag;
w = mag;

optarg = {};
if ~isempty(this.Frequency)
    optarg = {this.Frequency};
end

for k = 1:L
    linmod = getlinmod(this.ModelData(k).Model);
    if isempty(this.ModelData(k).Data.BodeResponse.w)
        [mag{k},ph{k},w{k}] = bode(linmod,optarg{:});
        this.ModelData(k).Data.BodeResponse = struct('w',w{k},'mag',mag{k},'phase',ph{k});
    else
        mag{k} = this.ModelData(k).Data.BodeResponse.mag;
        ph{k} = this.ModelData(k).Data.BodeResponse.phase;
        w{k} = this.ModelData(k).Data.BodeResponse.w;
    end
end

xlab = this.getXLabel('Frequency');

% populate axes
ny = length(ynames);
nu = length(unames);
ylabA = 'Amplitude';
ylabP = 'Phase (degrees)';
fnt = {};
if ny>1
    ylabA = 'Amp.'; 
    ylabP = 'Phase';
    fnt = {'FontSize',8};
end

for ky = 1:ny
    for ku = 1:nu
        % Ind are indices (i,j) of the current I/O pair in models
        [models, Ind] = this.findModelsWithChannel(unames{ku},ynames{ky});
        
        Lm = length(models);
        Lines = zeros(1,Lm*2);
        
        ax1 = subplot(ny*2,nu,2*(ky-1)*nu+ku,'parent',u2);        
        ax2 = subplot(ny*2,nu,(2*ky-1)*nu+ku,'parent',u2);
        
        for km = 1:Lm
            mInd = find(this.ModelData==models(km));
            Indkm = Ind(km,:);
            this.initializeAxes(ax1,'bode');
            
            if this.isGUI
                Lines(2*km-1) = loglog(ax1,w{mInd},squeeze(mag{mInd}(Indkm(2),Indkm(1),:)),...
                    'Color',models(km).Color,'tag',models(km).ModelName);
                if ~models(km).isActive
                    set(Lines(2*km-1),'visible','off');
                end
            else
                Lines(2*km-1) = loglog(ax1,w{mInd},squeeze(mag{mInd}(Indkm(2),Indkm(1),:)),...
                    models(km).StyleArg{:},'tag',models(km).ModelName);
            end
            hold(ax1,'on')
            
            this.initializeAxes(ax2,'bode');
            if this.isGUI
                Lines(2*km) = semilogx(ax2,w{mInd},squeeze(ph{mInd}(Indkm(2),Indkm(1),:)),...
                    'Color',models(km).Color,'tag',models(km).ModelName);
                if ~models(km).isActive
                    set(Lines(2*km),'visible','off');
                end
            else
                Lines(2*km) = semilogx(ax2,w{mInd},squeeze(ph{mInd}(Indkm(2),Indkm(1),:)),...
                    models(km).StyleArg{:},'tag',models(km).ModelName);
            end
            hold(ax2,'on')
        end
        
        hold(ax1,'off'), hold(ax2,'off')
        
        title(ax1,sprintf('From %s To %s',unames{ku},ynames{ky}));
        ylabel(ax1,ylabA,fnt{:});
        set(ax1,'xtickLabel','');
        
        ylabel(ax2,ylabP,fnt{:});
        if (ky==ny)
            xlabel(ax2,xlab,fnt{:}); 
        else
            set(ax2,'xtickLabel','');
        end
        
        setAllowAxesRotate(rotate3d(this.Figure),ax1,false);
        setAllowAxesRotate(rotate3d(this.Figure),ax2,false);
        axtag = [unames{ku},':',ynames{ky}];
        set(ax1,'parent',u2,'tag',['Mag:',axtag],'userdata','bode',...
            'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction(ax1,'bode'));
        set(ax2,'parent',u2,'tag',['Phase:',axtag],'userdata','bode',...
            'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction(ax2,'bode'));
        
        this.addLegend(ax1); 
        this.addLegend(ax2); 
        if ~isSinglePlot && (ny*nu)>4
            legend(ax1,'off')
            legend(ax2,'off')
        end
        
    end
end

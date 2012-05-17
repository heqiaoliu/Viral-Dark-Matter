function generateTimeRespPlot(this,type)
%Generate step or impulse plots for models this.ModelData
% type: 'step' or 'impulse'

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/31 06:13:43 $

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

isStep = strcmpi(type,'step');
if isSinglePlot
    %n = 1;
    [uname,yname] = this.decipherIOPair(v);
    unames = {uname}; ynames = {yname};
    %unames = unames(un);ynames = ynames(yn);
end

L = length(this.ModelData);
y = cell(1,L);
t = y;

optarg = {};
if ~isempty(this.Time)
    optarg = {this.Time};
end

for k = 1:L
    linmod = getlinmod(this.ModelData(k).Model);
    if isStep
        if isempty(this.ModelData(k).Data.StepResponse.t)
            [y{k},t{k}] = step(linmod,optarg{:});
            this.ModelData(k).Data.StepResponse = struct('t',t{k},'y',y{k});
        else
            y{k} = this.ModelData(k).Data.StepResponse.y;
            t{k} = this.ModelData(k).Data.StepResponse.t;
        end
    else
        if isempty(this.ModelData(k).Data.ImpulseResponse.t)
            [y{k},t{k}] = impulse(linmod,optarg{:});
            this.ModelData(k).Data.ImpulseResponse = struct('t',t{k},'y',y{k});
        else
            y{k} = this.ModelData(k).Data.ImpulseResponse.y;
            t{k} = this.ModelData(k).Data.ImpulseResponse.t;
        end
    end
end

xlab = this.getXLabel('Time');

% populate axes
k = 1;
ny = length(ynames);
nu = length(unames);
for ky = 1:ny
    for ku = 1:nu
        axk = subplot(ny,nu,k,'parent',u2);
        this.initializeAxes(axk,type);

        % Ind are indices (i,j) of the current I/O pair in models
        [models, Ind] = this.findModelsWithChannel(unames{ku},ynames{ky});
        if isempty(Ind)
            continue;
        end

        Lm = length(models);
        Lines = zeros(1,Lm);
        for km = 1:Lm
            mInd = find(this.ModelData==models(km));
            Indkm = Ind(km,:);
            if this.isGUI
                Lines(km) = plot(axk,t{mInd},squeeze(y{mInd}(:,Indkm(2),Indkm(1))),...
                    'Color',models(km).Color,'tag',models(km).ModelName);
                if ~models(km).isActive
                    set(Lines(km),'visible','off');
                end
            else
                Lines(km) = plot(axk,t{mInd},squeeze(y{mInd}(:,Indkm(2),Indkm(1))),...
                    models(km).StyleArg{:},'tag',models(km).ModelName);
            end
            hold(axk,'on')
        end
        hold(axk,'off')

        title(axk,sprintf('To %s',ynames{ky}));
        ylabel(axk,sprintf('From %s',unames{ku}));
        xlabel(axk,xlab); 
        setAllowAxesRotate(rotate3d(this.Figure),axk,false);
        set(axk,'parent',u2,'tag',[unames{ku},':',ynames{ky}],'userdata',type,...
            'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction(axk,type));
        
        this.addLegend(axk); 
        if ~isSinglePlot && (ny*nu)>4
            legend(axk,'off')
        end
        
        k = k+1;
    end
end


function generateNLPlot(this,type)
% generate NL prediction plots
% type may be 'input' or 'output'.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/08/01 12:22:57 $

isInput = strcmpi(type,'input');
N = this.NumSample;
this.createNewPlotPanel;
u2 = this.MainPanels(end);

if isInput
    iostr = 'Input';
    v = this.Current.InputComboValue;
    allnames = this.IONames.u;
else
    iostr = 'Output';
    v = this.Current.OutputComboValue;
    allnames = this.IONames.y;
end

if ~this.isGUI
    % we have multiple inputs/outputs option in combo
    v = v-1;
    if (v==0)
        isSinglePlot = false;
    else
        isSinglePlot = true;
    end
else
    isSinglePlot = true;
end

if isSinglePlot
    n = 1;
    nrow = 1;
    ncol = 1;
    allnames = allnames(v);
else
    n = length(allnames);
    ncol = round(sqrt(n));
    nrow = ceil(n/ncol);
end

for i1 = 1:length(allnames)
    name_i1 = allnames{i1};
    if isInput
        [model_i1, Ind_i1] = this.findModelsWithChannel(name_i1,[]);
    else
        [model_i1, Ind_i1] = this.findModelsWithChannel([],name_i1);
    end

    % set up i1'th axes
    ax_i1 = subplot(nrow,ncol,i1,'parent',u2);
    this.initializeAxes(ax_i1,lower(iostr));
 
    % populate ax_i1 with response curves from all applicable models
    L = length(model_i1);
    Lines_i1 = zeros(L,1);
    %nlnames = cell(1,L);
    nlobjs_i1 = cell(L,1);
    range0 = this.Range.(iostr);
    %range = zeros(L,2);
    range = zeros(0,2);
    for i2 = 1:L
        nlobjs_i1{i2} = model_i1(i2).Model.([iostr,'Nonlinearity'])(Ind_i1(i2));
        %nlnames{i2} = sprintf('%s:%s',model_i1(i2).ModelName,class(nlobjs_i1{i2}));
        if isempty(range0)
            rangei = nlobjs_i1{i2}.RegressorRange;
            if ~isempty(rangei)
                range(end+1,:) = rangei;
            end
        end
    end
    if isempty(range)
        range = [0 1];
    end

    if isempty(range0)
        range = [min(range(:,1)),max(range(:,2))];
        r = 0.1*diff(range);
        range = [range(1)-r, range(2)+r];
        this.Range.(iostr) = range;
    else
        range =  range0;
    end

    for i2 = 1:L
        xdata = (range(1):(range(2)-range(1))/(N-1):range(2))';
        ydata = evaluate(nlobjs_i1{i2}, xdata);
        if this.isGUI %&& model_i1(i2).isActive
            Lines_i1(i2) = plot(ax_i1,xdata,ydata,'Color',model_i1(i2).Color,...
                'tag',model_i1(i2).ModelName,'userdata',nlobjs_i1{i2});
            if ~model_i1(i2).isActive
                set(Lines_i1(i2),'visible','off');
            end
        else
            Lines_i1(i2) = plot(ax_i1,xdata,ydata,model_i1(i2).StyleArg{:},...
                'tag',model_i1(i2).ModelName,'userdata',nlobjs_i1{i2});
        end
        hold(ax_i1,'on')
    end
    hold(ax_i1,'off')

    %title(ax_i1,sprintf('Nonlinearity: %s',class(nlobj)));
    xlabel(ax_i1,sprintf('Input to nonlinearity at %s ''%s''',lower(iostr),name_i1))
    ylabel(ax_i1,'Nonlinearity Value')
    set(ax_i1,'parent',u2,'tag',[iostr,':',name_i1],'userdata',['nonlinear:',iostr],...
        'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction(ax_i1,lower(iostr)));

    this.addLegend(ax_i1); %legend(ax_i1,nlnames);
    if ~isSinglePlot && n>4
        legend(ax_i1,'off')
    end

    this.attachNonlinLimitChangeListener(ax_i1);
end


function addModel(this,mobj)
% Add model to the idnlhw plot figure
% This method is a callback to nlhwAdded event and may also be executed
% when a model is activated.
% mobj: nlhwdata object

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:51:01 $

if ~this.isGUI
    % adding models capability is for GUI only
    return;
end

name = mobj.ModelName;
model = mobj.Model;
obj = find(this.ModelData,'ModelName',name); %#ok<EFIND>

if ~isempty(obj)
    % this should not happen
    ctrlMsgUtils.warning('Ident:idguis:invalidModelObjState',name);
    %this.ModelData(this.ModelData==obj) = [];
    %delete(obj);
    this.removeModel(name);
end

this.ModelData = [this.ModelData;mobj];
localUpdateIONames(this,model);
this.updateCombos;

% input NL
uname = model.uname;
for k = 1:length(uname)
    localUpdateNLCurve(this,mobj,model,'Input',k);
end

% output NL
yname = model.yname;
for k = 1:length(yname)
    localUpdateNLCurve(this,mobj,model,'Output',k);
end

% linear
str = get(this.UIs.LinearPlotTypeCombo,'String');
for i1 = 1:length(yname)
    for i2 = 1:length(uname)
        for plottype = 1:4
            % 1: step; 2: bode; 3: impulse; 4: pzmap
            tag = sprintf('Linear:%s:%d',...
                this.getLinearComboString(uname{i2},yname{i1}),plottype);
            panel = findobj(this.MainPanels,'type','uipanel','tag',tag);
            if ~isempty(panel)
                localAddLinearResp(this,mobj,panel,i2,i1,uname,yname,plottype);
            end
        end
    end
end

this.showPlot;

%--------------------------------------------------------------------------
function localUpdateIONames(this,model)

unv = this.IONames.u;
ynv = this.IONames.y;

un = model.uname;
for  i = 1:length(un)
    if ~any(strcmp(unv,un{i}))
        unv = [unv;un{i}];
    end
end

yn = model.yname;
for  i = 1:length(yn)
    if ~any(strcmp(ynv,yn{i}))
        ynv = [ynv;yn{i}];
    end
end

this.IONames.u = unv;
this.IONames.y = ynv;

%--------------------------------------------------------------------------
function localUpdateNLCurve(this,mobj,model,iostr,k)

tag = [iostr,':',model.([iostr,'Name']){k}];
panel = findobj(this.MainPanels,'type','uipanel','tag',tag);
N = this.NumSample;

% do nothing if no panel is found
if ~isempty(panel)
    % add model to this panel's axes
    ax = findobj(panel,'type','axes','tag',tag);

    nlobj = model.([iostr,'Nonlinearity'])(k);

    % use existing range
    range = this.Range.(iostr);
    xdata = (range(1):(range(2)-range(1))/(N-1):range(2))';
    ydata = evaluate(nlobj, xdata);

    hold(ax,'on')
    L = plot(ax,xdata,ydata,'Color',mobj.Color,'tag',mobj.ModelName);
    set(L,'userdata',nlobj);
    this.addLegend(ax);
end

%--------------------------------------------------------------------------
function localAddLinearResp(this,mobj,panel,un,yn,unames,ynames,plottype)

switch plottype
    case {1,3}
        localAddTransientResp(this,mobj,panel,un,yn,unames,ynames,plottype);
    case 2
        localAddBodeResp(this,mobj,panel,un,yn,unames,ynames);
    case 4
        localAddPZMap(this,mobj,panel,un,yn,unames,ynames);
end

%--------------------------------------------------------------------------
function localAddTransientResp(this,mobj,panel,un,yn,unames,ynames,TypeInd)
% add new model's response to axes on current panel for step/impulse
% response plots.
% TypeInd: 1 for step, 3 for impulse.

isStep = TypeInd==1;

if isStep
    noData = isempty(mobj.Data.StepResponse.y);
else
    noData = isempty(mobj.Data.ImpulseResponse.y);
end

if noData
    linmod = getlinmod(mobj.Model);
    optarg = {};
    if ~isempty(this.Time)
        optarg = {this.Time};
    end
    
    if isStep
        [y,t] = step(linmod,optarg{:});
        mobj.Data.StepResponse = struct('t',t,'y',y);
    else
        [y,t] = impulse(linmod,optarg{:});
        mobj.Data.ImpulseResponse = struct('t',t,'y',y);
    end
else
    if isStep
        t = mobj.Data.StepResponse.t;
        y = mobj.Data.StepResponse.y;
    else
        t = mobj.Data.ImpulseResponse.t;
        y = mobj.Data.ImpulseResponse.y;
    end
end

xlab = this.getXLabel('Time');

ax = findobj(panel,'type','axes','tag',[unames{un},':',ynames{yn}]);
hold(ax,'on')
plot(ax,t,squeeze(y(:,yn,un)),'Color',mobj.Color,'tag',mobj.ModelName);

xlabel(ax,xlab);
this.addLegend(ax);

%--------------------------------------------------------------------------
function localAddBodeResp(this,mobj,panel,un,yn,unames,ynames)
% add new model's bode response to axes on current panel

if isempty(mobj.Data.BodeResponse.w)
    linmod = getlinmod(mobj.Model);
    optarg = {};
    if ~isempty(this.Frequency)
        optarg = {this.Frequency};
    end
    
    [mag,ph,w] = bode(linmod,optarg{:});
    mobj.Data.BodeResponse = struct('w',w,'mag',mag,'phase',ph);
else
    mag = mobj.Data.BodeResponse.mag;
    ph  = mobj.Data.BodeResponse.phase;
    w   = mobj.Data.BodeResponse.w;
end

xlab = this.getXLabel('Frequency');

ax1 = findobj(panel,'type','axes','tag',['Mag:',unames{un},':',ynames{yn}]);
ax2 = findobj(panel,'type','axes','tag',['Phase:',unames{un},':',ynames{yn}]);

hold(ax1,'on')
loglog(ax1,w,squeeze(mag(yn,un,:)),'Color',mobj.Color,'tag',mobj.ModelName);

hold(ax2,'on')
semilogx(ax2,w,squeeze(ph(yn,un,:)),'Color',mobj.Color,'tag',mobj.ModelName);

xlabel(ax2,xlab);
this.addLegend(ax1);
this.addLegend(ax2);

%--------------------------------------------------------------------------
function localAddPZMap(this,mobj,panel,un,yn,unames,ynames)
% add new model's pole-zero map to axes on current panel

if isempty(mobj.Data.PZMap.z) && isempty(mobj.Data.PZMap.p)
    linmod = getlinmod(mobj.Model);    
    [z,p] = zpkdata(linmod);
    mobj.Data.PZMap = struct('z',{z},'p',{p});
else
    z = mobj.Data.PZMap.z;
    p = mobj.Data.PZMap.p;
end

ax = findobj(panel,'type','axes','tag',[unames{un},':',ynames{yn}]);

hold(ax,'on')
zz = z{yn,un}; pp = p{yn,un};
plot(ax,real(zz),imag(zz),'o',real(pp),imag(pp),'x',...
    'Color',mobj.Color,'tag',mobj.ModelName);

this.addLegend(ax);

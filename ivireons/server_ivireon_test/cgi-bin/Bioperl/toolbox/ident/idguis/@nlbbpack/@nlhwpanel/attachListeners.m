function attachListeners(this,varargin)
% Attach listeners to nlhw panel options

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2009/07/09 20:52:19 $

h = handle(this.jModelOutputCombo,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', @(x,y)LocalOutputSelectionChanged(y,this));

h = handle(this.jApplySettingsCheckBox,'CallbackProperties');
L2 = handle.listener(h,'ItemStateChanged', @(x,y)LocalApplyToAllOutputs(y,this));

h = handle(this.jNonlinTableModel,'CallbackProperties');
L3 = handle.listener(h,'TableChanged', @(x,y)LocalNonlinTableChanged(y,this));

h = handle(this.jLinearTableModel,'CallbackProperties');
L4 = handle.listener(h,'TableChanged', @(x,y)LocalLinearTableChanged(y,this));

h = handle(this.jInferDelayButton,'CallbackProperties');
L5 = handle.listener(h,'ActionPerformed',@(x,y)LocalShowDelayInspector(this));

L6 = handle.listener(this,this.findprop('NlhwModel'),'PropertyPostSet',...
    {@LocalModelChangedCallback this});

this.Listeners = [L1,L2,L3,L4,L5,L6];

%--------------------------------------------------------------------------
function LocalOutputSelectionChanged(ed,this)
% output combo selection changed on linear panel

Ind = ed.JavaEvent.getSource.getSelectedIndex+1;

if (Ind==this.ActiveOutputIndex) || (Ind<1)
    return;
end

% refresh the contents of the dialog for new output
this.updateLinearPanelforNewOutput;

%-------------------------------------------------------------------------
function LocalNonlinTableChanged(ed,this)
% nonlinear config table changed

col = ed.JavaEvent.getColumn+1;
row = ed.JavaEvent.getFirstRow+1;
m = this.NlhwModel;
[ny,nu] = size(m);

% react only to user-initiated changes
if (col==0) || (row==1) || (row==(nu+2))
    return;
end

NLData = struct('Type',[],'Index',[]);
if (row<nu+2)
    currentnlobj = m.InputNonlinearity(row-1);
    NLData.Type = 'input';
    NLData.Index = row-1;
else
    currentnlobj = m.OutputNonlinearity(row-nu-2);
    NLData.Type = 'output';
    NLData.Index = row-nu-2;
end

if isa(currentnlobj,'wavenet')
    this.WaveNLData = NLData;
end

tablemodel = ed.Source;
charvalue = tablemodel.getValueAt(row-1,col-1);
alldata = cell(tablemodel.getData);

if (col==2)
    % nonlinearity type changed
    str = alldata{row,col};
    newnlobj = this.str2Obj(str);
    if strcmp(class(currentnlobj),class(newnlobj))
        return;
    end
    
    % update number of units
    if isa(newnlobj,'saturation') || isa(newnlobj,'deadzone')
        alldata{row,3} = ''; % "2" is not right (QZ)
    elseif isa(newnlobj,'sigmoidnet') || isa(newnlobj,'pwlinear')
        alldata{row,3} = int2str(newnlobj.NumberOfUnits);
    elseif isa(newnlobj,'wavenet')
        alldata{row,3} = 'Select automatically';
    elseif isa(newnlobj,'poly1d')
        alldata{row,3} = int2str(newnlobj.Degree);
    elseif isa(newnlobj,'customnet')
        alldata{row,3} = int2str(newnlobj.NumberOfUnits);
    else
        alldata{row,3} = '';
    end
elseif (col==3)
    % number of units changed
    newnlobj = currentnlobj;
    try
        % number of units changed
        if strcmpi(charvalue,'Select automatically')
            num = 'auto';
        elseif strcmpi(charvalue,'Select interactively during estimation')
            num = 'interactive';
        else
            % assume numerical entry
            if ~isa(newnlobj,'poly1d')
                errmsg = 'Number of units must be a finite positive integer.';
            else
                errmsg = 'Number of units for One-dimensional Polynomial refers to its degree. It must be a finite positive integer.';
            end
            errid = 'Ident:idguis:invalidNumUnits';
            try
                num = evalin('base',charvalue);
            catch
                error(errid,errmsg);
            end
            if ~isposintscalar(num)
                error(errid,errmsg);
            end
            alldata{row,col} = int2str(num);
        end
        if ~isa(newnlobj,'poly1d')
            newnlobj.NumberOfUnits = num;
        else
            newnlobj.Degree = num;
        end
        
    catch E
        errordlg(idlasterr(E),'Invalid Number of Units Specification','modal')
        if ~isa(currentnlobj,'poly1d')
            oldval = currentnlobj.NumberOfUnits;
        else
            oldval = currentnlobj.Degree;
        end
        if strncmpi(oldval,'auto',4)
            oldval = 'Select automatically';
        elseif strncmpi(oldval,'inte',4)
            oldval = 'Select interactively during estimation';
        else
            oldval = int2str(oldval);
        end
        alldata{row,col} = oldval;
        [alldata{:,4}] = deal('');
        tablemodel.setData(nlutilspack.matlab2java(alldata),[0,nu+1],0,size(alldata,1)-1);
        return
    end
elseif (col==4)
    % options button was pressed
    if isa(currentnlobj,'wavenet')
        p = com.mathworks.toolbox.ident.nnbbgui.NonlinPropInspector.getInstance;
        optionsobj = this.WavenetAdvancedOptions;
        nloptionspack.setAdvancedProperties(optionsobj); %update optionsobj with new data
        p.getPropertyViewPanel.setObject(optionsobj);
        p.showInspector('nonlin','Wavelet Network');
    elseif isa(currentnlobj,'saturation')
        if ~isempty(this.SaturationEditor) && ishandle(this.SaturationEditor)
            this.SaturationEditor.refresh(strcmpi(NLData.Type,'input'), NLData.Index);
        else
            % create new
            this.SaturationEditor = nlutilspack.deadsateditor(strcmpi(NLData.Type,'input'),...
                true, NLData.Index, this);
        end
    elseif isa(currentnlobj,'deadzone')
        if ~isempty(this.DeadzoneEditor) && ishandle(this.DeadzoneEditor)
            this.DeadzoneEditor.refresh(strcmpi(NLData.Type,'input'), NLData.Index);
        else
            % create new deadzone editor
            this.DeadzoneEditor = nlutilspack.deadsateditor(strcmpi(NLData.Type,'input'),...
                false, NLData.Index, this);
        end
    elseif isa(currentnlobj,'pwlinear')
        if ~isempty(this.PwlinearEditor) && ishandle(this.PwlinearEditor)
            this.PwlinearEditor.refresh(strcmpi(NLData.Type,'input'), NLData.Index);
        else
            % create new pwlinear editor
            this.PwlinearEditor = nlutilspack.pwlineareditor(strcmpi(NLData.Type,'input'),...
                NLData.Index,this);
        end
    elseif isa(currentnlobj,'poly1d')
        if ~isempty(this.Poly1dEditor) && ishandle(this.Poly1dEditor)
            this.Poly1dEditor.refresh(strcmpi(NLData.Type,'input'), NLData.Index);
        else
            % create new poly1d editor
            this.Poly1dEditor = nlutilspack.poly1deditor(strcmpi(NLData.Type,'input'),...
                NLData.Index,this);
        end
    elseif isa(currentnlobj,'customnet')
        if ~idIsValidHandle(this.UnitFcnDlg)
            nlgui = nlutilspack.getNLBBGUIInstance;
            this.UnitFcnDlg = nlutilspack.customnetunitfcndialog;
            this.UnitFcnDlg.initialize(nlgui.jGuiFrame,...
                {@LocalProcessUnitFunction this NLData.Type NLData.Index},currentnlobj);
        else
            this.UnitFcnDlg.refresh({@LocalProcessUnitFunction this NLData.Type NLData.Index},currentnlobj);
        end
        
        javaMethodEDT('setVisible',this.UnitFcnDlg.Frame,true);
        
    end
    return
else
    return
end

% update nonlinearity in the model if col==2 or col==3
if (row<nu+2)
    if this.isSingleInput
        m.InputNonlinearity = newnlobj;
    else
        m.InputNonlinearity(row-1) = newnlobj;
    end
else
    if this.isSingleOutput
        m.OutputNonlinearity = newnlobj;
    else
        m.OutputNonlinearity(row-nu-2) = newnlobj;
    end
end

this.updateModel(m);

[alldata{:,4}] = deal('');
tablemodel.setData(nlutilspack.matlab2java(alldata),[0,nu+1],0,size(alldata,1)-1);

if (col==2)
    % update diagram
    in = this.isAllLinear('input');
    out = this.isAllLinear('output');
    this.jMainPanel.setRightIcon(in,out);
end

% isestimated(model) need not be 0 depending upon conditions. Hence must
% fire event explicitly when nonlinearity is changed.
nlbbpack.sendModelChangedEvent('idnlhw');

%--------------------------------------------------------------------------
function LocalLinearTableChanged(ed,this)
% linear orders table updated

col = ed.JavaEvent.getColumn +1;
row = ed.JavaEvent.getFirstRow+1;

if (col==0)
    return;
end

tablemodel = ed.Source;
charvalue = tablemodel.getValueAt(row-1,col-1);
Ind = this.getCurrentOutputIndex;
m = this.NlhwModel;
alldata = cell(tablemodel.getData);
try
    if isempty(charvalue)
        ctrlMsgUtils.error('Ident:idguis:idnlhwInvalidOrder')
    end
    
    val = evalin('base',charvalue); %evaluated the entered expression
    if ~isnonnegintscalar(val)
        ctrlMsgUtils.error('Ident:idguis:idnlhwInvalidOrder')
    end
    % we have a valid scalar; update model
    m = nlbbpack.updateModelOrder(m,row,col,val,Ind*(~this.applyToAllOutputs));
    this.updateModel(m);
    
    alldata{row,col} = int2str(val);
catch E
    errordlg(idlasterr(E),'Invalid IDNLHW Model Order','modal')
    oldval = nlbbpack.getModelOrderInt(m,row,col,Ind);
    alldata{row,col} = int2str(oldval);
end

tablemodel.setData(nlutilspack.matlab2java(alldata),row-1,col-1);

%--------------------------------------------------------------------------
function LocalApplyToAllOutputs(ed,this)
% callback to checkbox for apply settings to all outputs
% disable output combo box
% update orders (nb, nf, nk)

% disable combo
if (ed.JavaEvent.getStateChange==java.awt.event.ItemEvent.DESELECTED)
    javaMethodEDT('setEnabled',this.jModelOutputCombo,true);
    this.applyToAllOutputs = false;
else
    javaMethodEDT('setEnabled',this.jModelOutputCombo,false);
    this.applyToAllOutputs = true;
    this.conformOutputs;
end

%--------------------------------------------------------------------------
function LocalShowDelayInspector(this)

messenger = nlutilspack.messenger;
ze = messenger.getCurrentEstimationData; %estimation data

close(findall(0,'type','figure','tag','ident:data:delayinspectiontool'))

Orders = {this.NlhwModel.nf,this.NlhwModel.nb};

nlutilspack.delayestim(this,ze,Orders);

%--------------------------------------------------------------------------
function LocalProcessUnitFunction(this, Type, Ind, fcn, varargin)
% update customnet unit function into the correct nonlinearity

m = this.NlhwModel;
if strcmpi(Type,'input')
    m.InputNonlinearity(Ind).UnitFcn = fcn;
else
    m.OutputNonlinearity(Ind).UnitFcn = fcn;
end

this.updateModel(m);

%--------------------------------------------------------------------------
function LocalModelChangedCallback(es,ed,this)
% IDNLARX model's properties were changed

m = this.NlhwModel;
if ~isa(m,'double')
    I = isestimated(m);
    if I==0 || (I==-1 && (~isinitialized(m.unl) || ~isinitialized(m.ynl)))
        % m contained structural changes
        nlbbpack.sendModelChangedEvent('idnlhw');
    end
end

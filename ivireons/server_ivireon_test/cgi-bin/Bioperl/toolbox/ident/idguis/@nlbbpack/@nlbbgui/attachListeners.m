function attachListeners(this,varargin)
% Attach listeners to GUI level options, such as Estimate.

% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.12 $ $Date: 2010/03/31 18:22:37 $

h1 = handle(this.jEstimateButton,'CallbackProperties');
% NOTE: if handle.listener is used, the button-pressed event is not fired
% unless the event queue is empty (or perhaps the previous callback from
% same button has not finished).
%L1 = handle.listener(h1,'ActionPerformed', @(es,ed)LocalPerformEstimation(this));
h1.ActionPerformedCallback = @(es,ed)LocalPerformEstimation(this);

messenger = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton
L2 = handle.listener(messenger,'identguichange',...
    @(es,ed)LocalDataChangedCallback(ed,this));

h2 = handle(this.jGuiFrame,'callbackproperties');
L3 = handle.listener(h2,'WindowClosed', @(es,ed)LocalNlbbguiClosingCallback(this));

h3 = handle(this.jGuiFrame.getMainPanel.getCloseButton,'CallbackProperties');
h3.ActionPerformedCallback = @(es,ed)this.jGuiFrame.doClose();

p = com.mathworks.toolbox.ident.nnbbgui.NonlinPropInspector.getInstance;
h4 = handle(p.getHelpButton,'CallbackProperties');
L4 = handle.listener(h4,'ActionPerformed', {@LocalPropInspectHelp,this,p});

h5 = handle(this.jGuiFrame.getMainPanel.getHelpButton,'CallbackProperties');
L5 = handle.listener(h5,'ActionPerformed', @LocalShowHelp);

sitbgui = getIdentGUIFigure;
this.FigureListener = addlistener(sitbgui,'ObjectBeingDestroyed',@(es,ed)this.jGuiFrame.doClose());

L7 = handle.listener(this,'VisibleModelChanged',{@LocalModelChangedCallback this.EstimationPanel});

this.Listeners = [L2,L3,L4,L5,L7];


%--------------------------------------------------------------------------
function LocalDataChangedCallback(ed,this)

switch ed.propertyName
    case 'eDataChanged'
        failure_status = this.ModelTypePanel.handleEstimDataChangedEvent(ed.NewValue);
        if failure_status
            wb = waitbar(0.1,'Estimation data has different I/O dimensions. Refreshing Nonlinear Models window...');
            L = this.jGuiFrame.getLocation;
            this.jGuiFrame.doClose; %event-thread method
            drawnow
            if idIsValidHandle(wb), waitbar(0.5,wb); end
            nlutilspack.getNLBBGUIInstance(true,true,L); %re-launch nlgui
            if idIsValidHandle(wb)
                waitbar(1,wb);
                close(wb)
            end
        end
    case 'vDataChanged'
        % do nothing
end

%--------------------------------------------------------------------------
function LocalPerformEstimation(this)
% callback to estimate/stop button pressed

if ~this.isIdle
    
    % disable stop button (now done is java callback)
    %this.jGuiFrame.getMainPanel.setBusy(2);
    
    % try to stop the estimation
    % (should not get here if non-iterative)
    this.EstimationPanel.OptimMessenger.Stop = true;
    
    %{
    this.jGuiFrame.setBlocked(false,[]);
    this.jGuiFrame.getMainPanel.setIdle;
    this.isIdle = true;
    %}
else
    try
        % set busy
        % disable estimate button  (now done is java callback)
        %this.jGuiFrame.getMainPanel.setBusy(0);
        this.isIdle = false;
        
        % set the focus to estimation result tab and estimate
        Tb = this.jGuiFrame.getMainPanel.getTabbedPane;
        
        I = Tb.getSelectedIndex;
        if I~=1
            javaMethodEDT('setSelectedIndex',Tb,1);
        end
        
        
        % 1. set glass pane
        this.jGuiFrame.setBlocked(true,[this.jEstimateButton]);
        
        % 2. clear out estimation panel
        % awtinvoke(EstimPanel.jInfoArea,'setText(Ljava.lang.String;)',java.lang.String(''));
        this.EstimationPanel.jMainPanel.clearContents; %event thread method
        
        % 3. Estimate model
        % a. update model for active output
        % b. print initial info in the estimation panel info area
        % c. collapse table if required
        % d. estimate model
        % e. update estimation results in info area and summary box
        try
            %this.estimate;
            [new_model,info] = this.ModelTypePanel.getCurrentModelPanel.estimate(this);
            Successful = true;
        catch E
            beep;
            errmsg = idlasterr(E);
            errordlg(errmsg,'Nonlinear Model Estimation Error','modal');
            S{1} = '<b>Estimation failed because of error.</b> Error message:<br>';
            S{2} = errmsg;
            this.EstimationPanel.jInfoArea.append(S);
            Successful = false;
        end
        
        if Successful
            % 4. put model into model board and set CurrentModel property
            iduiinsm(new_model,1,[],1);
            this.setLatestEstimModelName(new_model.Name);
            
            % 5. show final info in Estimation Summary
            fpestr = sprintf('%2.4g',new_model.EstimationInfo.FPE);
            lossfcnstr = sprintf('%2.4g',new_model.EstimationInfo.LossFcn);
            if isscalar(info.fit)
                fitstr = sprintf('%2.4g',info.fit);
            elseif isvector(info.fit)
                fitstr = sprintf('%2.4g',info.fit(1));
                for kk = 2:length(info.fit)
                    if rem(kk,2)==0
                        fitstr = [fitstr,sprintf(', %2.4g',info.fit(kk))];
                    else
                        fitstr = [fitstr,sprintf(',\n %2.4g',info.fit(kk))];
                    end
                end
            else
               fitstr = '<see Estimation Report>';
            end
            
            this.EstimationPanel.jMainPanel.setEstimationSummary({fitstr,fpestr,lossfcnstr});
            
            % 6. set initial model if so designated by user
            if this.EstimationPanel.jReiterateCheckBox.isSelected
                drawnow %need to make sure that modeladded callback has finished
                Type = class(new_model);
                this.ModelTypePanel.updateForNewInitialModel(Type,new_model.Name,false)
            end
        end
    end
    %7. remove glass pane and return to idle status
    this.jGuiFrame.setBlocked(false,[]);
    this.jGuiFrame.getMainPanel.setIdle;
    this.isIdle = true;
    this.EstimationPanel.IterTableIndices = 1;
    this.EstimationPanel.OptimMessenger.Stop = false;
end

%--------------------------------------------------------------------------
function LocalNlbbguiClosingCallback(this)
% clean up when gui closes

delete(this.ModelTypePanel.NlarxPanel.RegEditDialog.CustomRegEditDialog.Listeners);
delete(this.ModelTypePanel.NlarxPanel.RegEditDialog.Listeners);
delete(this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.wavenet.Listeners);
delete(this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.tree.Listeners);
delete(this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.sigmoid.Listeners);
delete(this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.neuralnet.Listeners);
delete(this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.custom.Listeners);
%delete(this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.linear.Listeners);
delete(this.ModelTypePanel.NlarxPanel.Listeners);
delete(this.ModelTypePanel.NlhwPanel.WavenetAdvancedOptions.Listeners);
delete(this.ModelTypePanel.NlhwPanel.Listeners);
delete(this.ModelTypePanel.InitModelDialog.Listeners);
delete(this.ModelTypePanel.Listeners);

delete(this.EstimationPanel.AlgorithmOptions(1).Listeners);
delete(this.EstimationPanel.AlgorithmOptions(2).Listeners);
delete(this.EstimationPanel.Listeners);

delete(this.Listeners);
delete(this.FigureListener);

hh = this.ModelTypePanel.InitModelDialog;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.jDialog);
end

hh = this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.custom.UnitFcnDlg;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Frame);
end

hh = this.ModelTypePanel.NlarxPanel.NonlinOptionsPanels.neuralnet.NetworkImportdlg;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Frame);
end

hh = this.ModelTypePanel.NlarxPanel.RegEditDialog.CustomImportdlg;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Frame);
end

hh = this.ModelTypePanel.NlhwPanel.SaturationEditor;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Handles.Dialog);
end

hh = this.ModelTypePanel.NlhwPanel.DeadzoneEditor;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Handles.Dialog);
end

hh = this.ModelTypePanel.NlhwPanel.PwlinearEditor;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Handles.Dialog);
end

hh = this.ModelTypePanel.NlhwPanel.Poly1dEditor;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Handles.Dialog);
end

hh = this.ModelTypePanel.NlhwPanel.UnitFcnDlg;
if idIsValidHandle(hh)
    javaMethodEDT('dispose',hh.Frame);
end
delete(findall(0,'type','figure','name','Training with TRAINLM','tag','train'));

%try
%nntraintool('close'); %can cause thread deadlocks
%trainTool = nnjava('nntraintool'); % can cause thread deadlock too
%awtinvoke(trainTool,'dispose()'); % this will just hide it, since it is a NNTB singleton
%end

delete(findall(0,'type','figure','tag','plottrainstate'))
delete(findall(0,'type','figure','tag','plotregression'))
delete(findall(0,'type','figure','tag','plotperform'))

delete(findall(0,'type','figure','tag','ident:data:delayinspectiontool'));

%delete(this.Listeners);
%this.Listeners = [];
delete(this);

%--------------------------------------------------------------------------
function LocalPropInspectHelp(es,ed,this,Inspector)

str = char(Inspector.getViewType);

if strcmpi(str,'nonlin')
    typestr = char(Inspector.getNonlinType);
    if strncmpi(typestr,'w',1)
        iduihelp('wavenet_adv.htm','Help: Wavelet Network Advanced Properties');
    else
        iduihelp('tree_adv.htm','Help: Tree Partition Advanced Properties');
    end
else
    iduihelp('nlalgorithm.htm','Help: Algorithm and Iteration Properties');
end

%--------------------------------------------------------------------------
function LocalShowHelp(varargin)

iduihelp('nlmodelestim.htm','Help: Nonlinear Models');

%--------------------------------------------------------------------------
function LocalModelChangedCallback(es,ed,est)
% visible model was changed; re-iteration checkbox should be unselected

if est.jReiterateCheckBox.isSelected
    javaMethodEDT('setSelected',est.jReiterateCheckBox,false)
    warndlg('The model refinement options under Estimate tab have been reset because of change in model configuration.',...
        'Model Configuration Change','modal')
end


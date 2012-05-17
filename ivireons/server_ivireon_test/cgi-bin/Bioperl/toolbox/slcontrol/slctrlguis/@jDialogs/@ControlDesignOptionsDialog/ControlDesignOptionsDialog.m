function hout = ControlDesignOptionsDialog(sisodb)
%  ControlDesignOptionsDialog Constructor for @ControlDesignOptionsDialog class
%
%  Author(s): John Glass
%  Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.13 $ $Date: 2009/11/09 16:35:59 $

    
% Create class instance
this = jDialogs.ControlDesignOptionsDialog;
 
this.sisodb = sisodb;
this.Design = sisodb.LoopData.exportdesign;

LocalConfigureDialog(this);

% Update the GUI with the new data from the linearization task
LocalUpdateDialog(this)
this.JavaPanel.setLocationRelativeTo(slctrlexplorer);
this.JavaPanel.pack;
javaMethodEDT('setVisible',this.JavaPanel,true);

hout = this;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateDialog - Update the dialog with the new node data
function LocalUpdateDialog(this)

% Design object
Design = this.Design;

% Get the handle to the Java object handles
jhand = this.JavaHandles;

% Sample Rate
ts = java.lang.String(num2str(Design.getTs));
javaMethodEDT('setText',jhand.SampleTimeEditField,ts);

% Rate conversion method
Method = Design.(Design.Tuned{1}).getProperty('C2DMethod');
switch Method{1};
    case 'zoh'
        algo = 0;
    case 'tustin'
        algo = 1;
    case 'prewarp'
        algo = 2;
end
javaMethodEDT('setSelectedIndex',jhand.RateConvAlgoCombo,algo);

% PreWarp Parameter
if isequal(length(Method),2)
    PreWarpFreq = num2str(Method{2});
else
    PreWarpFreq = num2str(1);
end
javaMethodEDT('setText',jhand.PreWarpFreqEditField,PreWarpFreq);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalConfigureDialog - Configure the dialog for the first time
function LocalConfigureDialog(this)

% Create the dialog panel
Frame = slctrlexplorer;
Dialog = javaObjectEDT('com.mathworks.toolbox.slcontrol.Dialogs.ControlDesignOptionsDialog',Frame);
Dialog.setSize(450,400);

% Store the java panel handle
this.JavaPanel = Dialog;

% Configure the panel
jhand.HelpButton = Dialog.getHelpButton;
h = handle(jhand.HelpButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHelpButtonCallback, this};
jhand.OKButton = Dialog.getOKButton;
h = handle(jhand.OKButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalOKButtonCallback, this};
jhand.ApplyButton = Dialog.getApplyButton;
h = handle(jhand.ApplyButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalApplyButtonCallback, this};
jhand.CancelButton = Dialog.getCancelButton;
h = handle(jhand.CancelButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelButtonCallback, this};

% These Java widgets do not need to have callbacks since the data is read
% when the Apply and OK buttons are presed
jhand.SampleTimeEditField = Dialog.getSampleTimeEditField;
jhand.PreWarpFreqEditField = Dialog.getPreWarpFreqEditField;
jhand.RateConvAlgoCombo = Dialog.getRateConvAlgoCombo;        

% Add listener for the case where the design task node is destroyed.
jhand.SISOTaskNodeListener = handle.listener(handle(getObject(getSelected(slctrlexplorer))), 'ObjectBeingDestroyed',...
                                    {@LocalCancelButtonCallback, this});
                                
% Store the java handles
this.JavaHandles = jhand;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHelpButtonCallback - Evaluate the help button callback
function LocalHelpButtonCallback(es,ed,this)

% Launch the help browser
scdguihelp('control_linearization_options',this.JavaPanel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOKButtonCallback - Evaluate the OK button callback
function LocalOKButtonCallback(es,ed,this)

% Call the apply callback
errorflag = LocalApplyButtonCallback([],[],this);

% Dispose of the dialog
if ~errorflag
    javaMethodEDT('dispose',this.JavaPanel);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalApplyButtonCallback - Evaluate the apply button callback
function errorflag = LocalApplyButtonCallback(es,ed,this)

% Initialize the error flag
errorflag = false;

sisodb = this.sisodb;
DesignData = this.Design;
InitialTs = DesignData.getTs; % initial sample time

% Get the Java handles
jhand = this.JavaHandles;

% Sample Time
try
    NewTs = evalScalarParam(linutil,char(jhand.SampleTimeEditField.getText));
catch Ex
    errordlg(Ex.message,'Simulink Control Design','modal')
    errorflag = true;
    return
end

if isequal(sisodb.LoopData.Ts, NewTs)
    errordlg('Sample time has not changed.',...
        'Simulink Control Design','modal')
    errorflag = true;
    return
end

try
    PreWarpFreq = evalScalarParam(linutil,char(jhand.PreWarpFreqEditField.getText));
catch Ex
    errordlg(Ex.message,'Simulink Control Design','modal')
    errorflag = true;
    return
end

% Rate conversion method
switch jhand.RateConvAlgoCombo.getSelectedIndex
    case 0
        RateConversionMethod = {'zoh'};
    case 1
        RateConversionMethod = {'tustin'};
    case 2       
        % PreWarp Parameter       
        RateConversionMethod = {'prewarp', PreWarpFreq};
end

% Determine target domain
if InitialTs == 0
    ToContinuous = false;
else
    ToContinuous = isequal(NewTs,0);
end

% Perform conversion
try
    if ToContinuous
        % D2C conversion
        ConvertFcn = 'd2c';
        Args = RateConversionMethod;
        ActionDetails = 'Converted the loop components to continuous time.';
    else
        % C2D or D2D conversion
        Args(:,1) = {NewTs};
        if InitialTs,
            % D2D conversion
            ConvertFcn = 'd2d';
            Args = [Args,RateConversionMethod];
            ActionDetails = sprintf('Resampled the loop components to new sample time of %0.3g seconds.',...
                NewTs);
        else
            ConvertFcn = 'c2d';
            Args = [Args,RateConversionMethod];
            ActionDetails = sprintf('Discretized the loop components using a sample time of %0.3g seconds.',...
                NewTs);
        end
    end
    
    newDesignData = DesignData;
      
    newDesignData.P.value = feval(ConvertFcn, newDesignData.P.Value,Args{1,:});
    
    % Perform conversion
    Components = DesignData.Tuned;
    numComponents = length(Components);
    for cnt = 1:numComponents
        if isequal(NewTs,newDesignData.(Components{cnt}).getProperty('TsOrig'))
            EvalFcn = newDesignData.(Components{cnt}).getProperty('Par2ZPKFcn');
            Parameters = newDesignData.(Components{cnt}).getProperty('Parameters');
            if iscell(EvalFcn)
                [zpkTuned,zpkFixed] = feval(EvalFcn{1},Parameters,EvalFcn{2:end});
            else
                [zpkTuned,zpkFixed] = feval(EvalFcn,Parameters);
            end
            newDesignData.(Components{cnt}).Value = zpkTuned*zpkFixed;
        else
            newDesignData.(Components{cnt}).Value = feval(ConvertFcn, ...
                DesignData.(Components{cnt}).Value,Args{1,:});
        end
       newDesignData.(Components{cnt}) = newDesignData.(Components{cnt}).setProperty('C2DMethod',RateConversionMethod);
       newDesignData.(Components{cnt}) = newDesignData.(Components{cnt}).setProperty('D2CMethod',RateConversionMethod);
    end
        
    % Convert Loops TunedLFT.IC for configuration 0
    % For standard configurations this is done through computeLoop
    Loops = newDesignData.Loops;
    for ct = 1:length(Loops)
        if strcmp(ConvertFcn,'c2d')
            opt = c2dOptions;
        elseif strcmp(ConvertFcn,'d2c')
            opt = d2cOptions;
        else
            opt = d2dOptions;
        end
        if numel(Args)==2
            opt.Method = Args{1,end};
        elseif numel(Args)==3
            opt.Method = 'tustin';
            opt.PrewarpFrequency = Args{1,end};
        end
        newDesignData.(Loops{ct}) = newDesignData.(Loops{ct}).setProperty('TunedLFTSSData',feval(ConvertFcn, ...
            DesignData.(Loops{ct}).getProperty('TunedLFTSSData'),Args{1,1},opt));
    end

catch Ex         
    errordlg(ltipack.utStripErrorHeader(Ex.message),'Conversion Error','modal');
    return    
end

% Unlock all axes limits
idxVis = find(strcmp(get(sisodb.PlotEditors,'Visible'),'on'));
for ct=idxVis',
    zoomout(sisodb.PlotEditors(ct));
end

% Import converted models 
LoopData = sisodb.LoopData;
EventMgr = sisodb.EventManager;

try
    % Start transaction
    T = ctrluis.transaction(LoopData,'Name','Conversion',...
        'OperationStore','on','InverseOperationStore','on');

    % Perform conversion and register transaction (error-free here)
    LoopData.importdata(newDesignData);

    % Commit and store transaction
    EventMgr.record(T);

    % Disable listener for closing the Conversion dialog when a DataChanged event is fired,
    % notify peers of data change, and reenable listener
    LoopData.send('ConfigChanged')  
    dataevent(LoopData,'all');

    % Update status and command history
    EventMgr.newstatus(ActionDetails);
    EventMgr.recordtxt('history',ActionDetails);
catch Ex
    T.Transaction.commit;
    delete(T);
    LoopData.importdata(DesignData);
    dataevent(LoopData,'all');
    errordlg(ltipack.utStripErrorHeader(Ex.message),'Conversion Error','modal');
    errorflag = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCancelButtonCallback - Evaluate the cancel button callback
function LocalCancelButtonCallback(es,ed,this)

% Dispose of the dialog
javaMethodEDT('dispose',this.JavaPanel);
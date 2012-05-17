function [new_model,info]  = estimate(this,h)
% perform nlhw estimation in the GUI
% h: handle to GUI main object (nnbbgui), for access to estimation panel and model
% name.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.13 $ $Date: 2009/07/09 20:52:20 $

% Tasks performed:
% 1. update model for active output
% 2. print initial info in the estimation panel info area
% 3. collapse table if required
% 4. estimate model and insert it into model board
% 5. update estimation results in info area and summary box

EstimPanel = h.EstimationPanel;
ModelName = h.ModelTypePanel.Data.idnlhw.ModelName;
messenger = nlutilspack.messenger;
ze = messenger.getCurrentEstimationData; %estimation data
ynames = messenger.getOutputNames;
unames = messenger.getInputNames;

% Update model name (if required) to ensure uniqueness
ModelName2 = nlutilspack.generateUniqueModelName('idnlhw',ModelName);
if ~strcmp(ModelName2,ModelName)
    ModelName = ModelName2;
    h.ModelTypePanel.Data.idnlhw.ModelName = ModelName;
    h.ModelTypePanel.jMainPanel.setModelName(java.lang.String(ModelName));
end

InitModelUsed = EstimPanel.jReiterateCheckBox.isSelected;
RandomizationUsed = EstimPanel.jRandomizeCheckBox.isSelected;

% Update idnlhw model for active output? Not required.
Model = this.NlhwModel;

% -- set algorithm properties
Alg = h.EstimationPanel.AlgorithmOptions(2).Algorithm;
X0 = h.EstimationPanel.AlgorithmOptions(2).Initial_State;
Model.Algorithm = Alg;

% Print initial info in the estimation panel info area
strs = LocalShowPreEstimationInfo;
EstimPanel.jInfoArea.append(strs);

% Collapse table if required
if nlutilspack.isNotIterativeEstimation(Model)
    javaMethodEDT('closePage',EstimPanel.jMainPanel,0);
else
    % do nothing because user may have intentionally closed table?
    javaMethodEDT('openPage',EstimPanel.jMainPanel,0);
end

% Estimate model
Model = pvset(Model,'OptimMessenger',h.EstimationPanel.OptimMessenger);
t = clock;
if RandomizationUsed
    % randomize initial model %todo: this is going to change
    if isestimated(Model)
        was = warning('off'); [lw,lwid] = lastwarn;
        Model = init(Model);
        warning(was), lastwarn(lw,lwid)
    else
        warndlg('Randomization requires a valid initial model.',...
            'Invalid Estimation Choice','modal')
        javaMethodEDT('setSelected',h.EstimationPanel.jRandomizeCheckBox,false);
    end
end

was = warning('off'); [lw,lwid] = lastwarn;
try
    new_model = pem(ze, Model, 'Display', 'off', 'InitialState', X0);
catch E
    warning(was), lastwarn(lw,lwid)
    throw(E)
end

% Update estimation info for data name; also restore status
es = new_model.EstimationInfo;
new_model.Name = ModelName;
es.DataName = ze.Name;
new_model = pvset(new_model,'EstimationInfo',es);

t = etime(clock,t);
wb = waitbar(0.25,'Computing fit to working data...');
[~,fit] = compare(ze, new_model);

warning(was), lastwarn(lw,lwid)

if idIsValidHandle(wb), waitbar(0.75,wb); end

strs = LocalShowPostEstimationInfo;
EstimPanel.jInfoArea.append(strs);

% todo: use Info for m-code recording
% every change in model must be recorded in nlhw/nlarxpanels.
info.fit = squeeze(fit);
if idIsValidHandle(wb), close(wb), end

% ------- inner function -------------------------------------------------
    function S = LocalShowPreEstimationInfo

        S = {};
        S{end+1} = '<body style="font-size:100%">';
        
        % header
        S{end+1} = sprintf('<h2>Estimation of Hammerstein-Wiener model: %s</h2>',ModelName);

        % data info
        Ne = size(ze,'ne');
        if Ne>1
            multiexpstr = sprintf(' in %d experiments.',Ne);
            Ns = ['[',num2str(size(ze,'ns')),']'];
        else
            multiexpstr = '.';
            Ns = num2str(size(ze,'ns'));
        end
        S{end+1} = sprintf('<b>Estimation Data:</b> ''%s'' with %s samples%s<br>',ze.Name,Ns,multiexpstr);

        % pre-estimation model info
        S{end+1} = '<h3>Model Configuration: </h3>';

        S{end+1} = '<b>Input nonlinearity:</b>';
        nlobj = Model.InputNonlinearity;
        if this.isSingleInput
            S{end+1} = sprintf(' %s.<br>',nlobj.getInfoString);
        else
            S{end+1} = '<br>';
            for i = 1:size(Model,'nu')
                S{end+1} = sprintf('&nbsp;<b>Input %d (%s): </b>%s.<br>',i,unames{i},nlobj(i).getInfoString);
            end
        end

        S{end+1} = '<br><b>Output nonlinearity:</b>';
        nlobj = Model.OutputNonlinearity;
        if this.isSingleOutput
            S{end+1} = sprintf(' %s.<br>',nlobj.getInfoString);
        else
            S{end+1} = '<br>';
            for i = 1:size(Model,'ny')
                S{end+1} = sprintf('&nbsp;<b>Output %d (%s): </b>%s.<br>',i,ynames{i},nlobj(i).getInfoString);
            end
        end
        
        if InitModelUsed
            %inim = h.ModelTypePanel.jInitialModelCombo.getSelectedItem;
            inim = this.LatestEstimModelName;            
            if ~RandomizationUsed
                S{end+1} = sprintf('This model is initialized using existing model <b>%s</b>.',inim);
            else
                S{end+1} = sprintf('This model is initialized using existing model <b>%s</b> with randomization of parameters.',inim);
            end
        end
        S{end+1} = '<hr>';
        S{end+1} = '<h3>Estimation Progress: </h3>';
        if InitModelUsed
            S{end+1} =  sprintf('Continuing iterations using <b>%s</b> as initial model...',inim);
        else
            S{end+1} =  sprintf('Estimating  ..........');
        end
    end %function:LocalShowPreEstimationInfo

%----------------------------------------------------------------------
    function S = LocalShowPostEstimationInfo
        S = {};
        S{1} = sprintf('done.<br>Completed in %8.5g seconds.<br>',t);
        S{2} = sprintf('%s<br>',new_model.EstimationInfo.WhyStop);
        S{end+1} = '<hr><h3>Results: </h3>';

        fitstr = nlutilspack.getFitStr(ze,fit);

        % FPE may be empty
        if isempty(new_model.EstimationInfo.FPE)
            FPEstr = '[]';
        else
            FPEstr = sprintf('<b>%2.4g</b>',new_model.EstimationInfo.FPE);
        end
        
        S{end+1} = sprintf('Final prediction error (FPE): %s, Loss function: <b>%2.4g</b><br>Fit to working data%s',...
            FPEstr, new_model.EstimationInfo.LossFcn, fitstr);

        S{end+1} = sprintf('<br>Model <b>%s</b> has been added to the model board. ',ModelName);
        S{end+1} = 'Suggested next steps in the System Identification Tool window:<br>';
        %{
        if false %iscstbinstalled
            S{end+1} = '-> To view the response of the linear approximation of this model about current input, drag the model icon to LTI Viewer rectangle.<br>';
        end
        %}
        S{end+1} = '-> To compare model output to validation data, select the Model output checkbox.<br>';
        S{end+1} = '-> To view a plot of the model''s I/O nonlinearities and the linear block, select the Hamm-Wiener checkbox.</body>';
    end % function
end
function [new_model,info]  = estimate(this,h)
% perform nlarx estimation in the GUI
% h: handle to GUI main object (nnbbgui), for access to estimation panel and model
% name.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.15 $ $Date: 2009/07/09 20:52:16 $

% Tasks performed:
% 1. update model for active output
% 2. print initial info in the estimation panel info area
% 3. collapse table if required
% 4. estimate model and insert it into model board
% 5. update estimation results in info area and summary box

EstimPanel = h.EstimationPanel;
ModelName = h.ModelTypePanel.Data.idnlarx.ModelName;
messenger = nlutilspack.messenger;
ze = messenger.getCurrentEstimationData; %estimation data
ynames = messenger.getOutputNames;

% Update model name (if required) to ensure uniqueness
ModelName2 = nlutilspack.generateUniqueModelName('idnlarx',ModelName);
if ~strcmp(ModelName2,ModelName)
    ModelName = ModelName2;
    h.ModelTypePanel.Data.idnlarx.ModelName = ModelName;
    h.ModelTypePanel.jMainPanel.setModelName(java.lang.String(ModelName));
end

InitModelUsed = EstimPanel.jReiterateCheckBox.isSelected;
RandomizationUsed = EstimPanel.jRandomizeCheckBox.isSelected;

if ~InitModelUsed
    
    % Update idnlarx model for active output:
    this.updateModelforActiveOutput; % current nonlinearity options
    
    %this.RegEditDialog.updateModelforActiveOutput; % for manually selected
    %regressors (not required anymore)
end

Model = this.NlarxModel;

% -- set algorithm properties
Alg = h.EstimationPanel.AlgorithmOptions(1).Algorithm;
Foc = h.EstimationPanel.AlgorithmOptions(1).Estimation_Focus;
%Alg.Weighting = eye(length(ynames));
Model.Algorithm = Alg;
Model.Focus = Foc;

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
    % randomize initial model
    if isestimated(Model)
        was = warning('off'); [lw,lwid] = lastwarn;
        Model = init(Model);
        warning(was), lastwarn(lw,lwid)
    else
        % should not get here
        warndlg('Randomization requires a valid initial model.',...
            'Invalid Estimation Choice','modal')
        javaMethodEDT('setSelected',h.EstimationPanel.jRandomizeCheckBox,false);
    end
end

was = warning('off'); [lw,lwid] = lastwarn;
try
    new_model = pem(ze, Model, 'Display', 'off','Focus',Foc);
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
        S{end+1} = sprintf('<h2>Estimation of Nonlinear ARX model: %s</h2>',ModelName);

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

        % regressors and nonlinearity
        R = Model.NonlinearRegressors; 
        nlobj = Model.Nonlinearity;
        if this.isSingleOutput
            S{end+1} = '<b>Model regressors:</b>';
            str = LocalPrintRegressors(Model);
            S{end+1} = sprintf('%s<br>',str);
            
            regstr = '<b>Regressors subset used for nonlinear block:</b> ';
            regstr = [regstr,LocalRegInd2Str(R)];
            S{end+1} = [regstr,'.<br>'];
            S{end+1} = '<br>';
            S{end+1} = sprintf('<b>Nonlinearity: </b>%s.<br>',nlobj.getInfoString);
        else
            for i = 1:size(Model,'ny')
                Ri = R{i};
                S{end+1} = sprintf('<b>Settings for Output %d (%s):</b><br>',i,ynames{i});
                
                S{end+1} = '<b>&nbsp;Model regressors for this output:</b>';
                str = LocalPrintRegressors(Model,i);
                S{end+1} = sprintf('&nbsp;%s<br>',str);
                
                regstr = '&nbsp;<b>Regressors subset used for nonlinear block for this output:</b> ';
                regstr = [regstr,LocalRegInd2Str(Ri)];
                S{end+1} = [regstr,'.<br>'];
                S{end+1} = '<br>';
                S{end+1} = sprintf('&nbsp;<b>Nonlinearity: </b>%s.<br>',nlobj(i).getInfoString);
                S{end+1} = '<br>';
            end
        end
        if InitModelUsed
            %inim = h.ModelTypePanel.InitModelDialog.jCombo.getSelectedItem;
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
            S{end+1} =  sprintf('Performing estimation with <b>Focus = %s</b>....<br>',Foc);
        end
    end %function:LocalShowPreEstimationInfo
%----------------------------------------------------------------------
    function S = LocalShowPostEstimationInfo
        S = {};
        S{1} = sprintf('done.<br>Completed in %8.5g seconds.<br>',t);
        S{2} = sprintf('%s<br>',new_model.EstimationInfo.WhyStop);
        S{end+1} = '<hr><h3>Results: </h3>';

        S{end+1} = sprintf('<b> Regressors used in the nonlinear block of model (if any):</b/><br>');
        R = getreg(new_model);
        RegInd = new_model.NonlinearRegressors;
        if this.isSingleOutput
            R = {R};
            RegInd = {RegInd};
        end
        for i = 1:size(Model,'ny')
            Ri = R{i};
            RegIndi = RegInd{i};
            if ischar(RegIndi)
                RegIndi = nlregstr2ind(new_model,RegIndi);
                if iscell(RegIndi)
                    RegIndi = RegIndi{i};
                end
            end
            Ri = Ri(RegIndi);

            % create regressors string from Ri
            regstr1 = '';
            if ~isempty(Ri)
                for k = 1:length(Ri)-1
                    regstr1 = [regstr1,Ri{k},', '];
                end
                regstr1 = [regstr1, Ri{end},'.'];
            end

            if ~this.isSingleOutput
                S{end+1} = sprintf('<b>&nbsp;For Output %d (%s): </b> %s <br>',i,ynames{i},regstr1);
            else
                S{end+1} = sprintf('%s<br>',regstr1);
            end
        end %for
        S{end+1} = '<br>';
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
        S{end+1} = '-> To view a plot of the nonlinearity, select the Nonlinear ARX checkbox.</body>'; 
    end % function

%----------------------------------------------------------------------
    function regstr = LocalRegInd2Str(regind)
        %generate a string for nonlin reg info

        if strcmpi(regind,'auto') || strcmpi(regind,'search')
            regstr = 'Search for best subset during estimation';
        elseif strcmpi(regind,'all')
            regstr = 'All regressors';
        elseif strcmpi(regind,'input')
            regstr = 'Standard regressors containing input variables only';
        elseif strcmpi(regind,'output')
            regstr = 'Standard regressors containing output variables only';
        elseif strcmpi(regind,'custom')
            regstr = 'Custom regressors only';
        elseif strcmpi(regind,'standard')
            regstr = 'Standard regressors only (no custom regressors)';
        else
            % numerical
            regstr = sprintf('[%s]',num2str(regind));
        end
    end %function LocalRegInd2Str
%--------------------------------------------------------------------------
    function str = LocalPrintRegressors(Model,Ind_)
        % print list of regressors
        reg_ = getreg(Model);
        if nargin>1
            reg_ = reg_{Ind_};
        end
        str = '';
        if ~isempty(reg_)
            for k = 1:length(reg_)-1
                str = [str,reg_{k},', '];
            end
            str = [str, reg_{end},'.'];
        end
        
    end %function LocalPrintRegressors

end %function:estimate

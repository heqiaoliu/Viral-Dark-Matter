function configSingleModel(this, thisModel, cs)
% Syntax:
%   called internally (protected function) with above parameters
%
% Description:
%   Builds an N row by 4 column cell array, with the columns defined as:
%       ModelName, Parameter, From, To
%
% Inputs:
%   current model name, active configset, and PIL type ('modelblock' or 'topmodel').
%
% Outputs:
%   Updates Configuration Set

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $

    ComponentType = this.ComponentType;

    IsERTTarget = get_param(cs, 'IsERTTarget');
    % PIL requirement: System Target File needs to be ERT derived
    if strcmp(IsERTTarget, 'off')
        settings.TemplateMakefile = 'ert_default_tmf';
        cs.switchTarget('ert.tlc',settings);
        this.CurrentModelChanged = true;
        % non-ERT targets implicitly support continuous time
        % carry over that behaviour if we have switched to ERT
        this.applyParam(cs, 'SupportContinuousTime', 'on');
    end
        
    % ERT Limitation
    % The ERT target only supports start time of 0
    this.applyParam(cs, 'StartTime', '0.0');
    
    % CodeInfo Limitation
    % GRTInterface should be disabled to generate CodeInfo
    this.applyParam(cs, 'GRTInterface', 'off');
    
    % CodeInfo Limitation
    % TargetLang should be set to "C" to generate CodeInfo
    this.applyParam(cs, 'TargetLang', 'C');
    
    % ERT Limitation
    % ERT derived STFs only support Fixed-step solver type
    this.applyParam(cs, 'SolverType', 'Fixed-step');
    
    % PIL Limitation
    % PIL errors out when this setting is on.
    this.applyParam(cs, 'GenCodeOnly', 'off');
    
    if strcmp(ComponentType, 'modelblock' )
        % PIL Limitation
        % Continuous Time is not supported for Model Block PIL completely.
        % For top model pil or pil block, we support continuous time as long as
        % the continuous time signals are not on the I/O boundary.
        % Unfortunately, we cannot detect this last condition easily, so we
        % don't enforce this setting for top model pil or pil block.
        this.applyParam(cs, 'SupportContinuousTime', 'off');
        
        % PIL Limitation
        % Absolute Time is not supported for Model Block PIL, but is supported
        % for pilblock and topmodel PIL, except at the I/O boundary.
        this.applyParam(cs, 'SupportAbsoluteTime', 'off');
        
        % PIL Limitation
        % For model block, PIL errors out when MatFileLogging is switched on,
        % so we need to set it off.
        this.applyParam(cs, 'MatFileLogging', 'off');
        
        % check C-API is not switched on
        % for the RTW target, this introduces extra complexity in the
        % code interface that we don't currently support for PIL.
        this.applyParam(cs, 'RTWCAPIParams', 'off');
        this.applyParam(cs, 'RTWCAPISignals', 'off');
        this.applyParam(cs, 'RTWCAPIStates', 'off');
    end
       
    if strcmp(ComponentType, 'topmodel' )
        % GenerateErtSFunction is not supported for Top-Model PIL
        this.applyParam(cs, 'GenerateErtSFunction', 'off');
        % External mode is not supported for Top-Model PIL
        this.applyParam(cs, 'ExtMode', 'off');                
    end
    
    % Top-Model PIL && TopModel only
    if strcmp(ComponentType, 'topmodel') && strcmp(thisModel, this.TopModel)
        % Top-Model PIL requires strict bus checking
        this.applyParam(cs, 'StrictBusMsg', 'ErrorLevel1');
    end
    
    % g546087:
    %
    % - Top-Model PIL does not support LoadInitialState
    % - Referenced models cannot have LoadInitialState switched on
    this.applyParam(cs, 'LoadInitialState', 'off');


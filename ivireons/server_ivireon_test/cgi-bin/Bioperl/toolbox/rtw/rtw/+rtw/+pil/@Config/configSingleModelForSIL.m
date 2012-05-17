%CONFIGSINGLEMODELFORSIL
% Syntax:
%   configSingleModelForSIL( this, thisModel, cs, ~) called internally (protected function) 
%
% Description:
%   Builds an N row by 4 column cell array, with the columns defined as:
%       ModelName, Parameter, From, To
% Inputs:
%   current model name, active configset, and the last parameter (type) is not used.
%
% Outputs:
%   Updates internal "changes" array
    
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

function configSingleModelForSIL(this, thisModel, cs)

    % At some time, the call to isValidParam threw.  Use a try/catch for extra safety.
    try
        hasTasking = cs.isValidParam('TaskingConfiguration');
    catch ME  %#ok<NASGU>
        hasTasking = false;
    end
    if hasTasking
        try
            tasking_removefrom_configset(cs);
            this.CurrentModelChanged = true;
        catch ME
            DAStudio.error( 'RTW:cgv:CannotRemoveTasking', gcs);
        end
    end
    configSingleModel(this, thisModel, cs);
    
    % configure emulation hardware SIL workflow
    this.applySILEmulationHardwareSettings(cs);                                                    
    
    % REVIEW: We think the following would be safest:
    %         1) Always switch to ert.tlc (done in configSingleModel)
    %         2) Always switch GenerateMakefile on
    %         3) Always set TemplateMakefile to ert_default_tmf
    %        
    
    % PIL Limitation
    % We need to set GenerateMakeFile to on for all types of PIL when we
    % are running on the host. This is because the 
    % HostDemoConnectivityConfig requires that the TemplateMakefile is set
    % to a supported value. If we turn GenerateMakeFile to off, then
    % TemplateMakefile is disabled.
    % Also TemplateMakefile needs to be set to a sensible value depending
    % on the host attributes we are running on. In this script, we will set
    % it to ert_default_tmf which will return the proper template make
    % file. 
    this.applyParam(cs, 'GenerateMakefile', 'on');
    this.applyParam(cs, 'TemplateMakefile', 'ert_default_tmf');   

    % per g541610
    if strcmpi(get_param(thisModel, 'GenerateSampleERTMain'), 'on')
        this.applyParam(cs, 'TargetOS', 'BareBoardExample');
    end            


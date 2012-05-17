function slbuild(mdl, varargin)
%SLBUILD Invoke the build procedure on a model 
%
% slbuild invokes the Real-Time Workshop build procedure to create either 
% a standalone executable or a model reference target for a model.
% The build procedure uses the model's configuration settings.
%
% slbuild('model') builds a standalone executable for the model.
%
% The following commands honors the setting of the "Rebuild option" 
% on the Model Referencing pane of the Configuration Parameters dialog 
% for rebuilding model reference target for this model and its
% referenced models.
%
% slbuild('model','ModelReferenceSimTarget') builds a model reference 
% simulation target for the model. 
%
% slbuild('model','ModelReferenceRTWTarget') builds model reference 
% simulation and RTW targets for the model.
%
% slbuild('model','ModelReferenceRTWTargetOnly') builds a model reference 
% RTW target for the model.
%
% If "Rebuild option" on the Model Referencing page of the Configuration 
% Parameters dialog is set to "Never", you can use
% 'UpdateThisModelReferenceTarget' parameter to specify a rebuild option
% for building a model reference target for this 'model'. For example,
%
% slbuild('model','ModelReferenceSimTarget', ...
%                 'UpdateThisModelReferenceTarget', Buildcond)  
% conditionally builds the simulation target for this 'model'.
% It does not rebuild model reference targets for models referenced 
% by this model. Buildcond specifies the condition for rebuilding this model. 
% It must be one of the following:
% 
%   * 'IfOutOfDateOrStructuralChange'
%   
%      Causes slbuild to rebuild this model if it detects
%      any changes. This option is equivalent to the "If any changes detected"
%      rebuild option on the Model Referencing page of the
%      Configuration Parameters dialog.
% 
%   *  'IfOutOfDate'
%
%      Causes slbuild to rebuild this model if it detects
%      any changes in known dependencies of this model. This
%      option is equivalent to the "If any changes in known
%      dependencies detected" rebuild option on the Model
%      Referencing page of the Configuration Parameters
%      dialog.
%
%   *  'Force'
%
%      Causes slbuild to always rebuild the model. This
%      option is equivalent to the "Always" rebuild option on
%      the Model Referencing page of the Configuration
%      Parameters dialog.

%   Copyright 1994-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.40 $

    sl('slbuild_private', mdl, varargin{:});

% eof

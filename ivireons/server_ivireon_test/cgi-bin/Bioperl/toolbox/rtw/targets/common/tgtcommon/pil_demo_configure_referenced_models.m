function pil_demo_configure_referenced_models(thisModel, thisConfigSet, models, configSets)
% PIL_DEMO_CONFIGURE_REFERENCED_MODELS - Demo helper function to
% switch configuration sets for a top-level model and a set of referenced
% models.
%
% pil_demo_configure_referenced_models(thisModel, thisConfigSet,
%                                      models, configSets)
%
% thisModel: The name of the top-level model
% thisConfigSet: The name of the configuration set for the top-level model
% models: The names of the referenced models
% configSets: The names of the configuration sets for the referenced models
%

% Copyright 2006 The MathWorks, Inc.

error(nargchk(4, 4, nargin, 'struct'));

if length(models) ~= length(configSets)
  TargetCommon.ProductInfo.error('pil', 'NumModelsEqualToConfigurationSets');
end

% setup the current model
load_system(thisModel);
setActiveConfigSet(thisModel, thisConfigSet);

% setup the referenced models
changedConfigSets = false;
%
for i=1:length(models)
   model = models{i};
   configSet = configSets{i};
   h = load_system(model);                     
   acs = getActiveConfigSet(h);
   if ~strcmp(acs.Name, configSet)
       % make sure model is writeable before proceeding
       % load_system will already have thrown an error if the model 
       % doesn't exist on the MATLAB path
       fpath = which(model);
       [success message messageid] = fileattrib(fpath);
       if ~success
          % unexpected error - throw it
          error(messageid, message);
       end
       if message.UserWrite~=1
         TargetCommon.ProductInfo.error('pil', 'FileNotWritable', fpath);
       end
       setActiveConfigSet(h, configSet);           
       changedConfigSets = true;
       save_system(h);                               
   end
end

if changedConfigSets
    % clean out the model reference shared
    % utilities directory in case of conflicts between hardware 
    % implementation settings
    sharedUtils = fullfile(pwd, 'slprj', 'sim', '_sharedutils', '*');
    delete(sharedUtils);
end

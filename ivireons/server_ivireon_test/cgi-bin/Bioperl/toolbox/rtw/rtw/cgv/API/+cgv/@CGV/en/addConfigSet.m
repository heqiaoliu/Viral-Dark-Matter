% cgv.CGV.addConfigSet
% 
% Add configuration set 
% 
% Syntax:
%   cgvObj.addConfigSet(configSet) 
%       Add a configuration set to the object. configSet is a handle to the 
%       configuration set.
%   cgvObj.addConfigSet('configSetName') 
%       Add a configuration set to the object.  configSetName is the name of the 
%       configuration set in the caller's workspace.
%   cgvObj.addConfigSet('file', 'configSetFileName') 
%       Add a configuration set to the object. configSetFileName is the name of a file 
%       that contains one configuration set.
%   cgvObj.addConfigSet('file', 'configSetFileName', 'var', 'configSetName') 
%       Add a configuration set to the object.  configSetName is the name of one of the 
%       configuration sets in configSetFileName.
%   
% Description:
%   This method replaces all configuration parameter values in the model with the values 
%   from the configuration set that you add.  
%   Note: This method has no effect after calling the run method.
%   

 
% Copyright 2000-2009 The MathWorks, Inc.


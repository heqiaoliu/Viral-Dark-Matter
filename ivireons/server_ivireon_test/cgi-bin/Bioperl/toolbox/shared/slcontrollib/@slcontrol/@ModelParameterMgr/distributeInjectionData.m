function distributeInjectionData(this,injdata)
% DISTRIBUTEINJECTIONDATA 
%
 
% Author(s): Erman Korkut 23-Feb-2009
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.10.1.6.1 $ $Date: 2010/06/28 14:19:33 $

util = slcontrol.Utilities;
models = this.getModels;
injdataDistModels = cell(length(models),1);
for ct = 1:length(injdata)
    modelname =  get(util.getModelHandleFromBlock(get_param(injdata(ct).PortHandle,'Parent')),'Name');
    % Append that model's injdata
    injdataDistModels{strcmp(modelname,models)}(end+1) = injdata(ct);
end
% Set them
for ct = 1:length(injdataDistModels)
    set_param(models{ct},'InjectionData',injdataDistModels{ct});
end



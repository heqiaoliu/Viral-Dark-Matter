function out = getInsertionInfo(this,injdata)
% GETINSERTIONINFO  
%
 
% Author(s): Erman Korkut 23-Feb-2009
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.10.3.2.1 $ $Date: 2010/06/28 14:19:34 $

util = slcontrol.Utilities;
models = this.getModels;
injdataDistModels = cell(length(models),1);
for ct = 1:length(injdata)
    modelname =  get(util.getModelHandleFromBlock(get_param(injdata(ct),'Parent')),'Name');
    % Append that model's injdata
    injdataDistModels{strcmp(modelname,models)}(end+1) = injdata(ct);
end

for ct = 1:length(injdataDistModels)
    set_param(models{ct},'InjectionData',injdataDistModels{ct});
end

insertioninfo = {};
for ct = 1:length(models)
    hMdl = getModelHandle(util,models{ct});
    try
        insertioninfo{end+1} = getInjectionDataForSignalBasedLinearization(hMdl);
    catch Me
        this.restoreModel;
        if any(cellfun(@(x)strcmp(x.identifier,'Simulink:SampleTime:InvPortBasedBlkInTrigSubsys'),Me.cause))
            ctrlMsgUtils.error('Slcontrol:frest:IOInAsyncSubsystem',this.Model)
        end        
        rethrow(Me)            
    end
    set_param(models{ct},'InjectionData',[]);
end
% Smooth the insertioninfo back to cell array
% First find the lengths
lens = cellfun(@length,insertioninfo);
out = insertioninfo{1};
for ct = 2:length(insertioninfo)
    out(end+1:end+lens(ct)) = insertioninfo{ct};
end


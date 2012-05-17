function this = prepareTunableParameters(this,variablelist)
% PREPARETUNABLEPARAMETERS 
%
 
% Author(s): Erman Korkut 02-March-2009
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.10.2.6.1 $ $Date: 2010/06/28 14:19:37 $

models = this.getModels;
this.TunableParametersAdded = variablelist;

for model_ct = 1:numel(models)
    origTunPars = get_param(models{model_ct},'TunableVars');
    origTunStorage = get_param(models{model_ct},'TunableVarsStorageClass');
    origTunQual = get_param(models{model_ct},'TunableVarsTypeQualifier');
    % Add parameters
    if ~isempty(origTunPars)
        set_param(models{model_ct},'TunableVars',strcat(origTunPars,',',variablelist));
    else
        set_param(models{model_ct},'TunableVars',variablelist);
    end
    if ~isempty(origTunStorage)
        set_param(models{model_ct},'TunableVarsStorageClass',strcat(origTunStorage,',Auto,Auto'));
    else
        set_param(models{model_ct},'TunableVarsStorageClass','Auto,Auto');
    end
    if ~isempty(origTunQual)    
        set_param(models{model_ct},'TunableVarsTypeQualifier',strcat(origTunQual,',,'));
    else
        % There should be a commas next to each other as many as # of total
        % parameters-1, i.e. # of commas in tunable variable list
        numcommas = numel(findstr(get_param(models{model_ct},'TunableVars'),','));
        for ct = numcommas:-1:1
            str(ct) = ',';
        end
        set_param(models{model_ct},'TunableVarsTypeQualifier',str);
    end
end

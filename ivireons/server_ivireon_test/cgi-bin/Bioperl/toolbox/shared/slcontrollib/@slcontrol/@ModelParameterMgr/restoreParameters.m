function restoreParameters(this)
% RESTOREPARAMETERS  
 
% Author(s): Erman Korkut 23-Feb-2009
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.10.3.2.1 $ $Date: 2010/06/28 14:19:39 $

models = this.getModels;

% Restore the linearization IO settings
if isempty(this.OrigLinIO) || isa(this.OrigLinIO,'linearize.IOPoint')
    linearize.setModelIOPoints(models,this.OrigLinIO);
end

for ct = numel(models):-1:1
    
    % Restore the parameters
    if ~isempty(this.OrigModelParams)
        f = fieldnames(this.OrigModelParams);
        for k = 1:length(f)
            prop = f{k};
            set_param(models{ct}, prop, this.OrigModelParams(ct).(prop));
        end
    end
    % Restore the tunable parameters added
    if ~isempty(this.TunableParametersAdded)
        str = get_param(models{ct},'TunableVars');
        ind = strfind(str,this.TunableParametersAdded);
        if ind~=1
            % There were already some parameters, remove the comma too.
            str(ind-1:end) = [];                        
        else
            % It was empty before, remove it
            str = '';
        end
        set_param(models{ct},'TunableVars',str);
        str = get_param(models{ct},'TunableVarsStorageClass');
        ind = strfind(str,'Auto,Auto');
        if ind~=1
            % There were already some parameters, remove the comma too.
            str(ind-1:end) = [];                        
        else
            % It was empty before, remove it
            str = '';
        end
        set_param(models{ct},'TunableVarsStorageClass',str);
        str = get_param(models{ct},'TunableVarsTypeQualifier');
        ind = strfind(str,',');
        if ind~=1
            % There were already some parameters, remove the comma too.
            str(ind-1:end) = [];
        else
            % It was empty before, remove it
            str = '';
        end
        set_param(models{ct},'TunableVarsTypeQualifier',str);
    end

    
end

% Restore checksum setting in multi-instance normal mode
normalrefmdls = this.NormalRefModels;
for ct = 1:numel(normalrefmdls)
    set_param(normalrefmdls{ct},'ModelReferenceMultiInstanceNormalModeStructChecksumCheck','error');
end

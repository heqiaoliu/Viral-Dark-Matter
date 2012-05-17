function prepareParameters(this,varargin)
% PREPAREPARAMETERS 
%
 
% Author(s): Erman Korkut 23-Feb-2009
% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.10.5.2.1 $ $Date: 2010/06/28 14:19:36 $

models = this.getModels;

% Make sure checksum does not create any problem in multi-instance normal
% mode case
normalrefmdls = this.NormalRefModels;
for ct = 1:numel(normalrefmdls)
    set_param(normalrefmdls{ct},'ModelReferenceMultiInstanceNormalModeStructChecksumCheck','none');
end

% Set the user defined properties
for ct = 1:((nargin-1)/2)
    DesiredParam = varargin{2*ct};
    switch varargin{2*ct-1}
        case 'ModelParameters'
            for model_ct = numel(models):-1:1
                if numel(DesiredParam)
                    f = fieldnames(DesiredParam);
                    for k = 1:length(f)
                        prop = f{k};
                        if strcmp(prop,'SCDLinearizationBlocksToRemove')
                            want_val = DesiredParam.(prop);
                            ind = strcmp(bdroot(want_val),models{model_ct});
                            want_val = want_val(ind);
                        elseif strcmp(prop,'StrictBusMsg')
                            want_val = DesiredParam.(prop);
                            % Bus setup: Get the new linearization I/O if
                            % any, it might be empty in root-level
                            % linearization
                            NewIO = [];
                            for ctvararg = 1:((nargin-1)/2)
                                if strcmp(varargin{2*ctvararg-1},'LinearizationIO')
                                    NewIO = varargin{2*ctvararg};
                                    break;
                                end
                            end
                            this.busLabelSetup(NewIO);
                        elseif strcmp(prop,'SCDPotentialLinearizationIOs')
                            % Find the portion of it in this model                            
                            want_val = LocalFindIOStructInThisModel(DesiredParam.(prop),models{model_ct});
                        else
                            want_val = DesiredParam.(prop);
                        end
                        have_val = get_param(models{model_ct}, prop);
                        set_param(models{model_ct}, prop, want_val);
                        old.(prop) = have_val;
                    end
                    oldsettings(model_ct) = old;
                end
            end
            this.OrigModelParams = oldsettings;
        case 'LinearizationIO'
            this.OrigLinIO = linearize.setModelIOPoints(models,DesiredParam);
    end
end
function iostructThisModel = LocalFindIOStructInThisModel(iostruct,thisMdl)
iostructThisModel = [];
util = slcontrol.Utilities;
for ct = 1:numel(iostruct)
    % Get the model name from block
    mdl = get(util.getModelHandleFromBlock(iostruct(ct).Block),'Name');
    if strcmp(mdl,thisMdl)
        iostructThisModel(end+1).Block = iostruct(ct).Block;
        iostructThisModel(end).Port = iostruct(ct).Port;
    end    
end

function this = ModelParameterMgr(Model,varargin)
% ModelParameterMgr Constructor

% Author(s): John Glass
%   Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4.2.1 $ $Date: 2010/06/21 18:02:44 $

% Construct the object
this = slcontrol.ModelParameterMgr;
this.Model = Model;
% Read the optional argument io
if nargin > 1
    io = varargin{1};
else
    io = [];
end

% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off',...
        'Name',this.Model))
    top_preloaded = 0;
    load_system(this.Model);
else
    top_preloaded = 1;
end

% Find the normal mode model references
[NormalModeModelBlks,NormalModeRefModels,IsLoadedNormalRefModel,AllRefModels] = getNormalModeBlocks(slcontrol.Utilities,this.Model);

% Error checking.  For blocks that are set to be normal mode model
% reference there cannot be any other references to the model.
for ct_outer = 1:numel(NormalModeRefModels)
    normal_instances_count = numel(find(strcmp(NormalModeRefModels{ct_outer},NormalModeRefModels)));
    normal_and_accel_instances_count = numel(find(strcmp(NormalModeRefModels{ct_outer},AllRefModels)));
    if normal_instances_count ~= normal_and_accel_instances_count
        % Normal and accelerator mode together
        % Clean up and error
        LocalCloseOpenedRefModels(Model,NormalModeRefModels,IsLoadedNormalRefModel,top_preloaded);
        ctrlMsgUtils.error( 'SLControllib:slcontrol:ModelRefFRESTIMATENormalAndAccelTogetherError', ...
            NormalModeRefModels{ct_outer});        
    elseif normal_instances_count > 1
        % Multi-instance normal mode
        % Check if any I/O on this model
        if LocalIsAnyIOInRefModel(NormalModeRefModels{ct_outer},io)
            % Clean up and error
            LocalCloseOpenedRefModels(Model,NormalModeRefModels,IsLoadedNormalRefModel,top_preloaded);
            ctrlMsgUtils.error( 'SLControllib:slcontrol:ModelRefFRESTIMATEMultiInstanceNormalModeError', ...
                NormalModeRefModels{ct_outer});
        end
    end
end

% Load the referenced models
for ct = 1:numel(NormalModeRefModels)
    if ~IsLoadedNormalRefModel(ct)
        load_system(NormalModeRefModels{ct});
    end
end

this.NormalRefModels = NormalModeRefModels;
this.NormalRefParentBlocks = NormalModeModelBlks;
this.OrigPreloaded = [top_preloaded;IsLoadedNormalRefModel];
this.TunableParametersAdded = [];
end

function LocalCloseOpenedRefModels(TopModel,NormalModeRefModels,IsLoadedNormalRefModel,Top_Preloaded)
for ct = numel(NormalModeRefModels):-1:1
    if ~IsLoadedNormalRefModel(ct)
        bdclose(NormalModeRefModels{ct});
    end
    if ~Top_Preloaded
        bdclose(TopModel);
    end
end
end

function out = LocalIsAnyIOInRefModel(model,io)
out = false;
for ct = 1:numel(io)
    if strcmp(bdroot(io(ct).Block),model)
        out = true;
        return;
    end
end
end

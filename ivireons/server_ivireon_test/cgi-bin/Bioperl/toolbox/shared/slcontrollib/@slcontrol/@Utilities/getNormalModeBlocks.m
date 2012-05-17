function [normalblks,normalrefs,isloaded,allrefmdls] = getNormalModeBlocks(this,mdl,varargin)
% GETNORMALMODEBLOCKS  Get the normal mode model reference blocks in a top
% level model.  The output variable allrefmdls list all of the occurrences
% of referenced models.
%

% Author(s): John W. Glass 05-Mar-2007
%   Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2010/04/11 20:36:56 $

% Parse inputs
if nargin == 2
    closeunopenedmodels = false;
else
    closeunopenedmodels = varargin{1};
end

% Determine if there are model blocks
mdlblks = find_system(mdl,'FollowLinks','on',...
            'LookUnderMasks','all',...
            'BlockType','ModelReference');
if ~isempty(mdlblks)
    ind_normal = strcmp(get_param(mdlblks,'SimulationMode'),'Normal');
else
    ind_normal = [];
end

% Start with the top model and recurse to find all the normal mode model
% references.
normalblks = {};
normalrefs = {};
isloaded = [];
allrefmdls = {};

if isempty(ind_normal)
    return
end    

% Find all the models that are open
open_diagrams = find_system('type','block_diagram');

% Determine if the top model is loaded
toploaded = any(strcmp(mdl,open_diagrams));
if ~toploaded
    load_system(mdl);
end

% Find all the model blocks
[refmdls,~] = find_mdlrefs(mdl);

% Find the normal mode model references
NestedFindMdlBlks(mdl)

    function NestedFindMdlBlks(mdl)
        mdlblks = find_system(mdl,'FollowLinks','on',...
            'LookUnderMasks','all',...
            'BlockType','ModelReference');
        ind_normal = strcmp(get_param(mdlblks,'SimulationMode'),'Normal');
        mdl_normalblks = mdlblks(ind_normal);
        mdl_normalrefs = get_param(mdl_normalblks,'ModelName');
        mdl_allrefmdls = get_param(mdlblks,'ModelName');
        mdl_isloaded = true(size(mdl_normalrefs));

        for ct = 1:numel(mdl_normalrefs)  
            if ~any(strcmp(mdl_normalrefs{ct},open_diagrams)) 
                load_system(mdl_normalrefs{ct});
                mdl_isloaded(ct) = false;
            end
        end
                
        % Store the model references and blocks
        normalblks = [normalblks;mdl_normalblks];
        normalrefs = [normalrefs;mdl_normalrefs];
        isloaded = [isloaded;mdl_isloaded];
        allrefmdls = [allrefmdls;mdl_allrefmdls];

        for ct = 1:numel(mdl_normalrefs)
            NestedFindMdlBlks(mdl_normalrefs{ct})
        end
    end

% Find all the models that are open after searching for the normal mode
% model references.
allopen_diagrams = find_system('type','block_diagram');

% Be sure all the reference models are open
allisloaded = true(numel(refmdls),1);
for ct_outer = 1:numel(refmdls)
    if ~any(strcmp(refmdls{ct_outer},allopen_diagrams))
        load_system(refmdls{ct_outer});
        allisloaded(ct_outer) = false;
    end
end

% Close all extra model references
for ct_outer = 1:numel(allisloaded)
    if ~allisloaded(ct_outer)
        close_system(refmdls{ct_outer})
    end
end

% Close the opened models if requested
if closeunopenedmodels
    for ct_outer = 1:numel(isloaded)
        if ~isloaded(ct_outer)
            close_system(refmdls{ct_outer})
        end
    end
end

% Close the top model
if ~toploaded
    close_system(mdl);
end

end

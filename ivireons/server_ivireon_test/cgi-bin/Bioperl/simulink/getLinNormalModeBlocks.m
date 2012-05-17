function [normalblks,normalrefs,isloaded] = getLinNormalModeBlocks(mdl,varargin)
% GETLINNORMALMODEBLOCKS  Get the normal mode model reference blocks in a top
% level model.
 
% Author(s): John W. Glass 05-Mar-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/08/20 16:41:51 $

% Parse inputs
if nargin == 1
    closeunopenedmodels = false;
else
    closeunopenedmodels = varargin{1};
end

% Find all the models that are open
open_diagrams = find_system('type','block_diagram');

% Determine if the top model is loaded
toploaded = any(strcmp(mdl,open_diagrams));
if ~toploaded
    load_system(mdl);
end

% Find all the model blocks
[refmdls,modelblks] = find_mdlrefs(mdl);

% Start with the top model and recurse to find all the normal mode model
% references.
normalblks = {};
normalrefs = {};
isloaded = [];

% Find the normal mode model references
NestedFindMdlBlks(mdl)

    function NestedFindMdlBlks(mdl)
        mdlblks = find_system(mdl,'FollowLinks','on',...
            'LookUnderMasks','all',...
            'BlockType','ModelReference');
        ind_normal = strcmp(get_param(mdlblks,'SimulationMode'),'Normal');
        mdl_normalblks = mdlblks(ind_normal);
        mdl_normalrefs = get_param(mdl_normalblks,'ModelName');
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

% Get all of the referenced models in the list that have been instantiated
refmdl_ins = get_param(modelblks,'ModelName');

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

% Error checking.  For blocks that are set to be normal mode model
% reference there cannot be any other references to the model.
for ct_outer = 1:numel(normalrefs)
    if numel(find(strcmp(normalrefs{ct_outer},refmdl_ins))) > 1
        % If there is an error the outer functions will not be able to
        % clean up any models that are loaded
        if ~closeunopenedmodels
            for ct_outer2 = 1:numel(isloaded)
                if ~isloaded(ct_outer2)
                    close_system(refmdls{ct_outer2})
                end
            end
        end
        DAStudio.error('Simulink:tools:linmodNotSupportedMultipleModelReference',normalrefs{ct_outer})
    end
end

end
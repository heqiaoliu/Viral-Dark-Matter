function str = getDirtyLoadedModels(mdlName) 
% GETDIRTYLOADEDMODELS  Returns the list of models that are loaded and
% dirty.
%
 
% Author(s): Erman Korkut 16-Jun-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:19 $

% Quick return if model is not yet open
if isempty(find_system('type', 'block_diagram','Name',mdlName))
    str = '';
    return;
end

ctrlUtil = slcontrol.Utilities;
[~,mdlRef,isLoaded] = ctrlUtil.getNormalModeBlocks(mdlName);
mdlCheck = vertcat(mdlRef(isLoaded==1),mdlName);
dirty = get_param(mdlCheck,'Dirty');
idx = strcmp(dirty,'on');
if any(idx)
    strMdls = mdlCheck(idx);
    str = sprintf(strMdls{1});
    for ct=2:numel(strMdls)
        str = sprintf('%s, %s',str,strMdls{ct});
    end
else
    str = '';
end

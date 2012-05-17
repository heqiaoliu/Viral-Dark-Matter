function name = getUniqueBlockName(this,block,varargin)
% GETUNIQUEBLOCKNAME(THIS,PORT) - Gets the unique block name among the
% parent and the referenced models given the full block path.

%  Author(s): John Glass
%  Revised: Erman Korkut
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/04/11 20:36:57 $

% Get the block name
blockname = get_param(block,'Name');

% Get the parent and referenced models
if nargin > 2
    ModelParameterMgr = varargin{1};
    if isa(ModelParameterMgr,'slcontrol.ModelParameterMgr')
        refmodels = ModelParameterMgr.NormalRefModels;
    else
        refmodels = ModelParameterMgr.getUniqueNormalModeModels;
        refmodels = refmodels(2:end);
    end
    prtmodel = ModelParameterMgr.Model;
else
    prtmodel = this.getModelHandleFromBlock(block);
    prtmodel = prtmodel.Name;
    refmodels = [];
end

% Get the blocks with same name in the parent model
blocks = find_system(prtmodel,...
    'findall','on',...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'type','block',...
    'Name',blockname);
% Remove the new line and carriage returns in the model/block name
blocks = cellstr(regexprep(getfullname(blocks),'\n',' '));

% Get the blocks with the same name in the current model
curmodel = this.getModelHandleFromBlock(block);
curmodel = curmodel.Name;
if ~strcmp(curmodel,prtmodel)
    curblocks = find_system(curmodel,...
        'findall','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','block',...
        'Name',blockname);
    % Add the found blocks to the original blocks
    blocks(end+1:end+length(curblocks)) = cellstr(regexprep(getfullname(curblocks),'\n',' '));
end

% Search other referenced models also if any
% Exclude current block diagram from the referenced model to avoid double counting
refmodels = setdiff(refmodels,{curmodel});
for ct = 1:length(refmodels)
   refblocks = find_system(refmodels{ct},...
       'findall','on',...
       'FollowLinks','on',...
       'LookUnderMasks','all',...
       'type','block',...
       'Name',blockname);
   % Add the found blocks to the original blocks
   blocks(end+1:end+length(refblocks)) = cellstr(regexprep(getfullname(refblocks),'\n',' '));
end      

% Get the index into the blocks list and remove new line and carriage returns
block = regexprep(block,'\n',' ');
blk_ind = find(strcmp(strtrim(block),strtrim(blocks)));
unblks = uniqname(this,blocks,true);
name = strtrim(unblks{blk_ind});

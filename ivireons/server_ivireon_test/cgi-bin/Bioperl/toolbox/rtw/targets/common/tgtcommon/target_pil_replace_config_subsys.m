function target_pil_replace_config_subsys(action, libName, srcBlkName, fullDstBlkName)
%TARGET_PIL_INSERT_CONFIG_SUBSYS  Insert Configurable Subsystem in place of original block

% Copyright 2002-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/11/13 04:57:57 $

% Get names needed to do replacement                                       
fullSrcBlkName = sprintf([libName, '/', strrep(srcBlkName, '/', '//')]);   

% make sure the destination model exists and is open
%
% find the root model of the destination path
% Note: model names cannot contain /'s so we are ok
% to use strtok
dstModel = strtok(fullDstBlkName, '/');
% Make sure the original model is open                                     
load_system(dstModel);                                                     

% make sure the block to remove exists
try 
  find_system(fullDstBlkName, 'SearchDepth', 0);
catch e
    TargetCommon.ProductInfo.error('pil', 'BlockToRemoveNotFound', fullDstBlkName);
end

% make sure the blockToInsert doesn't exist
fullInsertBlkName = [get_param(fullDstBlkName, 'Parent') '/' strrep(srcBlkName, '/', '//')];
try 
  find_system(fullInsertBlkName, 'SearchDepth', 0);
  block_found = true;
catch e %#ok<NASGU>
  block_found = false;
end
%
if block_found  
  TargetCommon.ProductInfo.error('pil', 'BlockToInsertFound', fullInsertBlkName);
end

% Get block parameters from destination block                           
dstPos = get_param(fullDstBlkName, 'Position');                           
dstParent = get_param(fullDstBlkName, 'Parent');

% Open parent system of the destination block
open_system(dstParent);

% Delete destination block and copy in the source block                    
delete_block(fullDstBlkName);                                              
add_block(fullSrcBlkName, fullInsertBlkName, 'Position', dstPos);          

switch action                                                              
case 'insert'                                                              
  % No further action                                                        
case 'revert'                                                              
  % Break library link on new destination block if the block                 
  % in the PIL library is not a link from some other library.                
  if strcmp(get_param(fullSrcBlkName, 'LinkStatus'), 'none')                 
    set_param(fullInsertBlkName, 'LinkStatus', 'none');
  end
end

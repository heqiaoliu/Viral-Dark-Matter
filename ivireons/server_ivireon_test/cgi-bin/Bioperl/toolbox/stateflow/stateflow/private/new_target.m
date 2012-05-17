function newTarget = new_target(parentId,newTargetName)
%NEW_TARGET(parentId)

%   Jay R. Torgerson
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.18.2.9 $  $Date: 2008/08/08 13:10:05 $

allTargets = sf('TargetsOf', parentId);
if(nargin<2)
   newTargetName = unique_name_for_list(allTargets, 'target');
end

newTarget = sf('new','target'...
   ,'.name',newTargetName...
   ,'.linkNode.parent',parentId...
   );

if(strcmp(newTargetName,'rtw') || strcmp(newTargetName,'sfun'))
   return;
end

targetFile = find_target_files(newTargetName);
if ~isempty(targetFile)
    sf('set',newTarget,'target.targetFunction',targetFile.fcn);
end

target_methods('initialize',newTarget);

function target_name_change(target)

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2008/12/01 08:08:18 $

targetName = sf('get',target,'target.name');

targetFile = find_target_files(targetName);
if ~isempty(targetFile)
    sf('set',target,'target.targetFunction',targetFile.fcn);
end

target_methods('namechange',target);

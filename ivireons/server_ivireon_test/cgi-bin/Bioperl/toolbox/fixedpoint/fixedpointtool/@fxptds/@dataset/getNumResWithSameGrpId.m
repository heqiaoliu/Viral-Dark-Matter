function numResWithSameGrpId =  getNumResWithSameGrpId(ds,resObj)
% This is a method that figures out the total number of blocks in a given shared DT GroupID of the result object.
% This takes into account the results that are not visible on the FPT. This is also used by FPA to 
% display the number of results sharing the same GroupID.


%   Author(s): V. Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:56:38 $



run = fxptui.str2run(resObj.Run);    
allResWithSameGrpId = ds.getlist4id(run, resObj.DTGroup);
numResWithSameGrpId = numel(allResWithSameGrpId);
for k = 1:numel(allResWithSameGrpId)
    if ~allResWithSameGrpId(k).isVisible
        numResWithSameGrpId = numResWithSameGrpId - 1;
    end
end


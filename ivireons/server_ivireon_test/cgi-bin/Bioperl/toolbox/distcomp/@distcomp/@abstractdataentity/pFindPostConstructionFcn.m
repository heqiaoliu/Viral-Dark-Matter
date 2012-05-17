function [index, varargout] = pFindPostConstructionFcn(obj, fcn)
; %#ok Undocumented

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/06/24 17:00:41 $ 

postConstructionFcns = obj.PostConstructionFcns;
% Find fcn in the first column of the PostConstrution fcns
index = find(cellfun(@(x) isequal(x, fcn), postConstructionFcns(:, 1)), 1, 'first');

nArgOut = nargout - 1;
% Return output arguments if index is not empty
if isempty(index)
    varargout = cell(1, nArgOut);
else
    varargout = postConstructionFcns{index, 2};
end

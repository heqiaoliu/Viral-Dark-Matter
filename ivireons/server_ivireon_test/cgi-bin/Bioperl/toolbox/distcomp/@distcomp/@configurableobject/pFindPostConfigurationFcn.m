function [index, varargout] = pFindPostConfigurationFcn(obj, fcn)
; %#ok Undocumented

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/08/26 18:13:18 $ 

postConfigurationFcns = obj.PostConfigurationFcns;
% Find fcn in the first column of the PostConstrution fcns
index = find(cellfun(@(x) isequal(x, fcn), postConfigurationFcns(:, 1)), 1, 'first');

nArgOut = nargout - 1;
% Return output arguments if index is not empty
if isempty(index)
    varargout = cell(1, nArgOut);
else
    varargout = postConfigurationFcns{index, 2};
end

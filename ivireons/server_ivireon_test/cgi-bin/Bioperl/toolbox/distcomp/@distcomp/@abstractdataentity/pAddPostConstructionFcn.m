function pAddPostConstructionFcn(obj, fcn, varargin)
; %#ok Undocumented

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/08/26 18:13:12 $ 


% See if we can find fcn in the first column of the PostConstrution fcns
index = find(cellfun(@(x) isequal(x, fcn), obj.PostConstructionFcns(:, 1)), 1, 'first');

if isempty(index)
    % If not already here add this fcn to the end of the available list
    obj.PostConstructionFcns(end + 1, :) = {fcn varargin};
else
    % Else put it in the right place
    obj.PostConstructionFcns(index, :) = {fcn varargin};
end
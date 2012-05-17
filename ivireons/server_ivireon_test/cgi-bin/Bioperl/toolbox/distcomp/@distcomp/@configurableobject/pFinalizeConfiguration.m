function pFinalizeConfiguration(obj)
; %#ok Undocumented
%pFinalizeConfiguration carry out any post Configuration tasks

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/08/26 18:13:17 $ 

% Indicate that the object has now been constructed
obj.IsBeingConfigured = false;

postConfigurationFcns = obj.PostConfigurationFcns;
obj.PostConfigurationFcns = cell(0, 2);
% And remember to carry out any post-construction task like attaching
% the callback eventing correctly
if ~isempty(postConfigurationFcns)
    for j = 1:size(postConfigurationFcns, 1)
        thisFcn = postConfigurationFcns(j, :);
        feval(thisFcn{1}, obj, thisFcn{2}{:});
    end
end

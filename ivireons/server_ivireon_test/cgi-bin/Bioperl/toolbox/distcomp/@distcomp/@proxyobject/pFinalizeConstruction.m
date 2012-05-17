function pFinalizeConstruction(obj)
; %#ok Undocumented
%pFinalizeConstruction carry out any post construction tasks

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/06/24 17:01:45 $ 

% Indicate that the object has now been constructed
obj.IsBeingConstructed = false;

postConstructionFcns = obj.PostConstructionFcns;
obj.PostConstructionFcns = cell(0, 2);
% And remember to carry out any post-construction task like attaching
% the callback eventing correctly
if ~isempty(postConstructionFcns)
    for j = 1:size(postConstructionFcns, 1)
        thisFcn = postConstructionFcns(j, :);
        feval(thisFcn{1}, obj, thisFcn{2}{:});
    end
end

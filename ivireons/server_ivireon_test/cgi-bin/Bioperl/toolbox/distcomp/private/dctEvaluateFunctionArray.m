function dctEvaluateFunctionArray(fcns)
; %#ok Undocumented
%dctEvaluateFunctionArray 
%
%  dctEvaluateFunctionArray(functionArray)

%  Copyright 2006-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/10/02 18:43:14 $ 

% Evaluate the list of functions (assumed to be a cell array of either
% function handles or cell array of callbacks)
for i = 1:numel(fcns)
    thisFcn = fcns{i};
    try
        if iscell(thisFcn)
            feval(thisFcn{1}, thisFcn{2:end});
        else
            feval(thisFcn);
        end
    catch e
        throw(distcomp.ExitException(e, 'dctEvaluateFunctionArray'));
    end
end

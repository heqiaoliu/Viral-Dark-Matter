function OK = pTaskStateComparison(operator, currentState, desiredState)
; %#ok Undocumented
%pTaskStateComparison 
%
%  OK = pTaskStateComparison(op, currentState, desiredState)

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/07/14 03:52:54 $ 

persistent validStates
if isempty(validStates)
    % Get the defined execution states from the enum
    type = findtype('distcomp.taskexecutionstate');
    validStates = type.Strings;
end

% Lets check if we have gone beyond the desired state
currentIndex = find(strcmp(currentState, validStates));
desiredIndex = find(strcmp(desiredState, validStates));

OK = feval(operator, currentIndex, desiredIndex);
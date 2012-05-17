function OK = pJobStateComparison(operator, currentState, desiredState)
; %#ok Undocumented
%pJobStateComparison 
%
%  OK = pJobStateComparison(currentState, desiredState)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:40:22 $ 

persistent validJobStates
if isempty(validJobStates)
    % Get the defined execution states from the enum
    type = findtype('distcomp.jobexecutionstate');
    validJobStates = type.Strings;
end

% Lets check if we have gone beyond the desired state
currentIndex = find(strcmp(currentState, validJobStates));
desiredIndex = find(strcmp(desiredState, validJobStates));

OK = feval(operator, currentIndex, desiredIndex);
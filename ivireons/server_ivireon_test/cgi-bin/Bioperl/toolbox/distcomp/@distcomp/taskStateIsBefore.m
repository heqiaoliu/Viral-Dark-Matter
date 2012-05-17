function OK = taskStateIsBefore(currentState, desiredState)
; %#ok Undocumented
%taskStateIsBefore 
%
%  OK = taskStateIsBefore(currentState, desiredState)

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/07/14 03:52:56 $ 

OK = distcomp.pTaskStateComparison(@lt, currentState, desiredState);
function OK = taskStateIsAfter(currentState, desiredState)
; %#ok Undocumented
%taskStateIsAfter 
%
%  OK = taskStateIsAfter(currentState, desiredState)

%  Copyright 2009 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2009/07/14 03:52:55 $ 

OK = distcomp.pTaskStateComparison(@gt, currentState, desiredState);
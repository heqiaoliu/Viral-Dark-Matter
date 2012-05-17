function OK = jobStateIsAtOrBefore(currentState, desiredState)
; %#ok Undocumented
%jobStateIsBefore 
%
%  OK = jobStateIsBefore(currentState, desiredState)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/10/02 18:40:20 $ 

OK = distcomp.pJobStateComparison(@le, currentState, desiredState);
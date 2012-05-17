function nop(varargin)
; %#ok Undocumented
%NOP No operation function
%   This function takes no arguments, does nothing and results as much.
%   It is a great function if you want nothing to be done. Otherwise, it is
%   just used for the tasks 2 to N in a MatlabPool job submission.
    
% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.3 $    $Date: 2008/12/29 01:47:56 $

% There is a race condition where one matlabpool lab starts executing code
% from the client lab before the others, errors out, and causes the other
% labs to error during startup code. To aleviate this we request that all
% labs get to this point before any be allowed to execute parallel language
% code. This is somewhat like the pctWorldLabBarrier in dctEvaluateTask.
% Note that this is NOT a pctWorldLabBarrier as it is only the pool labs
% that are barriering (since the MPI communicators have already be
% correctly formed).
labBarrier;
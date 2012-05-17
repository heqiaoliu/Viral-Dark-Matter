%throwAsCaller Issue exception as if from calling function.
%   throwAsCaller(ME) throws an exception from the currently running
%   M-file that is based on MException object ME. MATLAB exits the
%   currently running function and returns control to either the keyboard
%   or an enclosing CATCH block in a calling function. Unlike the THROW
%   function, MATLAB omits the current stack frame from the STACK field
%   of the MException, thus making the exception look as if it is being
%   thrown by the caller of the function.
%
%   Example:
%      % Run this function passing input 2*pi. MATLAB reports the error as
%      % if it was caught by the top-level function.
%
%      function klein_bottle(ab)
%      rtr = [2 0.5 1];   pq = [40 40];
%      box = [-3 3 -3 3 -2 2];   vue = [55 60];
%      draw_klein(ab, rtr, pq, box, vue)
%
%      function draw_klein(ab, rtr, pq, box, vue)
%      try
%         tube('xyklein',ab, rtr, pq, box, vue);
%      catch ME
%         throwAsCaller(ME)
%      end
%
%   See also MException, THROW, RETHROW, STACK, ERROR, ASSERT, TRY, CATCH.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/02/25 08:09:57 $
%   Built-in function.

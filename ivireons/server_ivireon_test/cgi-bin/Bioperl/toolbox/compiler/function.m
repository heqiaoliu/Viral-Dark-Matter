%FUNCTION MATLAB Compiler pragma.
%   The statement
%      %#function
%   may appear anywhere in an M-file defining a function.
%   Since it begins with a % sign, it is taken to be a comment by the
%   MATLAB interpreter.  But, to the MATLAB Compiler, MCC, it is an
%   indication that the code will directly or indirectly call each named
%   function using an FEVAL statement.  The Compiler then adds these functions
%   to a table of functions that will be called using FEVAL in the generated code.
%
%   See also MCC.

% $Revision: 1.5.4.1 $  $Date: 2008/12/04 22:19:34 $
% Copyright 1984-2002 The MathWorks, Inc.



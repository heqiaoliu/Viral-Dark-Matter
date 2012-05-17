%NARGCHK Validate number of input arguments. 
%   MSGSTRUCT = NARGCHK(LOW,HIGH,N,'struct') returns an appropriate error
%   message structure if N is not between LOW and HIGH. If N is in the
%   specified range, the message structure is empty. The message structure
%   has at a minimum two fields, 'message' and 'identifier'.
%
%   MSG = NARGCHK(LOW,HIGH,N) returns an appropriate error message string if
%   N is not between LOW and HIGH. If it is, NARGCHK returns an empty matrix. 
%
%   MSG = NARGCHK(LOW,HIGH,N,'string') is the same as 
%   MSG = NARGCHK(LOW,HIGH,N).
% 
%   Example
%      error(nargchk(1, 3, nargin, 'struct'))
%
%   See also NARGOUTCHK, NARGIN, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.12.4.5 $  $Date: 2005/06/27 22:49:59 $
%   Built-in function.

function hStack = overflowstack(limit)
%OVERFLOWSTACK Construct an overflow stack
%   OVERFLOWSTACK(LIMIT) Construct a stack whose maximum length is LIMIT.
%   If not entered, the stack will default to 20.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:07 $

if nargin == 0, limit = 20; end

hStack = sigutils.overflowstack;

set(hStack,'StackLimit',limit);

% [EOF]

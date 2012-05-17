function boolflag = isfull(this)
%ISFULL Returns true if the stack is full.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:15 $

% Return true if the amount of data is = or > the stack limit
% The > should not be necessary, but it is included as a precaution
% against careless subclass method adding above the limit.
boolflag = length(this) >= this.Limit;

% [EOF]

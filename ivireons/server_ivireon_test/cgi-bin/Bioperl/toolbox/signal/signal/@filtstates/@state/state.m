function this = state(value)
%STATE   Construct a STATE object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:44:34 $

this = filtstates.state;

if nargin
    this.Value = value;
end

% [EOF]

function le = set_length(this, le)
%SET_LENGTH   PreSet function for the 'length' property.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:11:11 $

if le < 1
    error(generatemsgid('invalidLength'), 'The length cannot be less than 1.');
end

set(this, 'LengthOption', 'Specified', ...
    'privLength', le);

le = [];

% [EOF]

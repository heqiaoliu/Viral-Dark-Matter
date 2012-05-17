function this = tf(num, den)
%TF   Construct a TF object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:20:30 $

this = lwdfilt.tf;

if nargin > 0,
    set(this, 'Numerator', num);
    set(this, 'refnum', num);
    if nargin > 1
        set(this, 'Denominator', den);
        set(this, 'refden', den);
    end
end

% [EOF]

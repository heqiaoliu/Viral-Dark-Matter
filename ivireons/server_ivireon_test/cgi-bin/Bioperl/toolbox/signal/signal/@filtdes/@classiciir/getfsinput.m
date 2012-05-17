function fsinput = getfsinput(this)
%GETFSINPUT   Return the Fs part of the input for GENMCODE.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:36:16 $

if strcmpi(this.freqUnits, 'normalized (0 to 1)'),
    fsinput = '';
else
    fsinput = ', Fs';
end

% [EOF]

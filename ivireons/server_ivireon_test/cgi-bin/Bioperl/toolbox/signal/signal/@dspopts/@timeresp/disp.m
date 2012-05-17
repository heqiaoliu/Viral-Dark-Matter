function disp(this)
%DISP   Display this object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:11:07 $

props = {'NormalizedFrequency'};

if ~this.NormalizedFrequency
    props{end+1} = 'Fs';
end

props{end+1} = 'LengthOption';

if strcmpi(this.LengthOption, 'Specified')
    props{end+1} = 'Length';
end

siguddutils('dispstr', this, props);

% [EOF]

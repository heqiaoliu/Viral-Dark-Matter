function disp(this)
%DISP   Display this object.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:10:35 $

props = {'Name', 'Data', 'NormalizedFrequency'};

if ~this.NormalizedFrequency
    props{end+1} = 'Fs';
end

siguddutils('dispstr', this, props);

% [EOF]

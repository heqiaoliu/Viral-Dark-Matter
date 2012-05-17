function hFs = fsspecifier
%FSSPECIFIER Constructor for the sampling frequency specifier

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:18:45 $

error(nargchk(0,0,nargin,'struct'));

hFs = siggui.fsspecifier;

setstate(hFs,defaultfs);
set(hFs,'Version',1);


% -----------------------------------------------------
function specs = defaultfs

specs.units = 'Normalized (0 to 1)';
specs.value = 'Fs';

% [EOF]

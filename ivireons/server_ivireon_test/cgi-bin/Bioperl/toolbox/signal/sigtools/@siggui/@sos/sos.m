function hSOS = sos(filtobj)
%SOS Create an SOS Converter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:19:59 $ 

error(nargchk(1,1,nargin,'struct'));

hSOS = siggui.sos;

hSOS.Filter = filtobj;

set(hSOS,'Version',1);
settag(hSOS);

% [EOF]

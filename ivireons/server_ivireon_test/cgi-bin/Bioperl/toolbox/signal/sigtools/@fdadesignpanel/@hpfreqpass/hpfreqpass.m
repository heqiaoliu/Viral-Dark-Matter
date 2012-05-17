function this = hpfreqpass
%HPFREQPASS  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2005/06/16 08:40:37 $

this = fdadesignpanel.hpfreqpass;
set(this, 'FPass', '14400'); %Use a different default

% [EOF]

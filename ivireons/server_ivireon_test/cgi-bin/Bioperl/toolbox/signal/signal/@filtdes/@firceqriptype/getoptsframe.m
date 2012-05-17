function fr = getoptsframe(h)
%GETOPTSFRAME  Return constructors of frames needed for FDATool.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2009/05/23 08:15:21 $

% Override the options frame for this method
fr.constructor = 'siggui.firceqripoptsframe';
fr.setops        = {};       

% [EOF]

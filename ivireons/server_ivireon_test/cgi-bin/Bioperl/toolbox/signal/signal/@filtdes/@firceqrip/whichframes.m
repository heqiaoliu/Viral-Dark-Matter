function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2009/05/23 08:15:19 $

% Call the base method
fr = super_whichframes(h);

% Override the options frame for this method
fr(end) = getoptsframe(h.responseTypeSpec);




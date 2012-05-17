function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:43:13 $

% Call alternate method
fr = super_whichframes(h);

% Add the options frame
fr(end+1).constructor = 'siggui.iirlpnormcoptsframe';
fr(end).setops        = {};
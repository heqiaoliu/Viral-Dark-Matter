function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:36:36 $

% Call the base method
fr = dm_whichframes(h);

% Get frames needed by filter order
fr(end+1).constructor = 'siggui.filterorder';
fr(end).setops        = {'isMinOrd',0};       

% Add the FIRLPNORM specific options frame
fr(end+1).constructor = 'siggui.firlpnormoptsframe';
fr(end).setops        = {};       





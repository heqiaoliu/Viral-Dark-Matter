function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:25:46 $

% Call super's method
fr = dmom_whichframes(h);

% Add the remez specific frame instead of the textoptionsframe
indx = find(strcmpi({fr.constructor},'siggui.textOptionsFrame'));
fr(indx).constructor = 'siggui.firwinoptionsframe';
fr(indx).setops        = {};

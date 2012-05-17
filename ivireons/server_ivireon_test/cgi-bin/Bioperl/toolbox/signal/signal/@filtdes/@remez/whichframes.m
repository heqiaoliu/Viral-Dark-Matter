function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:48:53 $

% Call super's method
fr = dmom_whichframes(h);

% Add the remez specific frame instead of the textoptionsframe
indx = find(strcmpi({fr.constructor},'siggui.textOptionsFrame'));
fr(indx).constructor = 'siggui.remezoptionsframe';
fr(indx).setops        = {};


function w = getGraphicalBorderWidth(h)
% Return width of uipanel graphical border in pixels.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:17 $ 

% Width is returned in pixels from BorderWidth property, regardless of
% setting of units property.  If BorderType is set to 'EtchedIn' or
% 'EtchedOut', the width of the graphical border is twice the reported
% value.

scale = 2 * strncmpi(get(h,'BorderType'),'etched',6);
w = scale * get(h,'BorderWidth');

function highlightString = getHighlightString(~, type)
%GETHIGHLIGHTSTRING Get the highlightString.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:16 $

% Make this a static method when converting to MCOS.
if nargin > 1 && strcmp(type, 'tooltip')
    highlightString = 'Highlight Simulink signal';
else
    highlightString = sprintf('Highlight Simulink Signal');
end

% [EOF]

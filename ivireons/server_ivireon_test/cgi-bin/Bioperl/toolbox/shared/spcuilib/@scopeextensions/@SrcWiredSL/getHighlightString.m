function highlightString = getHighlightString(~, type)
%GETHIGHLIGHTSTRING Get the highlightString.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:19 $

if nargin > 1 && strcmp(type, 'tooltip')
    highlightString = 'Highlight Simulink block';
else
    highlightString = 'Highlight Simulink Block';
end

% [EOF]

function copyfigure(this)
%COPYFIGURE   Copy the axes to a figure and put on the clipboard.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 19:04:44 $

hFig = copyaxes(this);

editmenufcn(hFig, 'EditCopyFigure');

close(hFig);

% [EOF]

function printpreview(this, varargin)
%PRINTPREVIEW   Display preview of figure to be printed

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:20:22 $

hFig = copyaxes(this);

if isempty(hFig),
    warning(generatemsgid('GUIWarn'),'Nothing to print, select either Time or Frequency Domain.');
    return;
end

if nargin > 1,
    set(hFig, varargin{:});
end

hWin_printprev = printpreview(hFig);
uiwait(hWin_printprev);

delete(hFig)

% [EOF]

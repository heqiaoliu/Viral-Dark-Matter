function print(this, varargin)
%PRINT   Print the figure.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:20:21 $

hFig_print = copyaxes(this);

if isempty(hFig_print),
    warning(generatemsgid('GUIWarn'),'Nothing to print, select either Time or Frequency Domain.');
    return;
end

if nargin > 1,
    set(hFig_print, varargin{:});
end

hFig = get(this, 'FigureHandle');

setptr(hFig,'watch');        % Set mouse cursor to watch.
printdlg(hFig_print);
setptr(hFig,'arrow');        % Reset mouse pointer.
close(hFig_print);

% [EOF]

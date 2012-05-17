function thisunrender(hDlg)
%THISUNRENDER Unrender the dialog

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2009/01/05 18:00:38 $

deletewarnings(hDlg);

hFig = get(hDlg, 'FigureHandle');
if ~isempty(hFig) & ishghandle(hFig),
    delete(hFig);
end

% [EOF]

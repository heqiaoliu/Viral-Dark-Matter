function thisunrender(this)
%THISUNRENDER Unrender for the parameter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.2.4.6 $  $Date: 2010/04/05 22:42:53 $

for indx = 1:numel(this.BaseListeners)
    delete(this.BaseListeners{indx});
end

hFig = get(this, 'FigureHandle');
if ~isempty(hFig) && ishghandle(hFig),
    delete(hFig);
end

% Not sure why this was here but it was causing problems.
% % Reset the parameters.
% hPrm = get(this, 'Parameters');
% for indx = 1:length(hPrm)
%     send(hPrm(1), 'UserModified', sigdatatypes.sigeventdata(hPrm(1), ...
%     'UserModified', get(hPrm(1), 'Value')));
% end

% [EOF]

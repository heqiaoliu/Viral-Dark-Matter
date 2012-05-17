function destroy(hView)
%DESTROY Delete the winviewer object

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:37:05 $

% Destroy the parameterdlg if needed
paramdlg = get(hView, 'ParameterDlg');
if ~isempty(paramdlg),
    destroy(paramdlg);
end

% R13
% super::destroy(hView);
% hBListeners = get(hView,'BaseListeners');
% 
% % Check for cell arrays to allow for vector inputs
% if iscell(hBListeners),
%     hBListeners = [hBListeners{:}];
% end
% 
% delete(hBListeners);
delete(hView);

% [EOF]

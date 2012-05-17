%
%
%
function exportViewsCallback(h, callbackArgs)

%   Copyright 2009 The MathWorks, Inc.

if strcmp(callbackArgs, 'ok')
    [filename, pathname] = uiputfile({'*.mat','MAT-files (*.mat)';}, ...
                                     DAStudio.message('Shared:DAS:ExportViewsDialogTitle'));
    if ~isequal(filename, 0) && ~isequal(pathname, 0)
        fullFile = [pathname filename];    
        % Get file name and export all views.
        h.export(h.VMProxy.BufferedViews, fullFile);
    end
end

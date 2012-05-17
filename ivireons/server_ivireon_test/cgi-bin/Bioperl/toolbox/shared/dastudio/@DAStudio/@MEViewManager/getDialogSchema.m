%
% Dialog schema for view management.
%
function dlg = getDialogSchema(h, type)

%   Copyright 2009 The MathWorks, Inc.

switch (type)
    case 'manage'
        dlg = h.getStandaloneDialogSchema();
    case {'export' 'import'}
        dlg = h.getExportImportDialogSchema(type);
    otherwise
        dlg = h.getEmbeddedDialogSchema();    
end
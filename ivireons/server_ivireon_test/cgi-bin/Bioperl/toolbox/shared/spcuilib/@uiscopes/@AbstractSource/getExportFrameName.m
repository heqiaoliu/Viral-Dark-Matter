function exportFrameName = getExportFrameName(this)
%GETEXPORTFRAMENAME Get the exportFrameName.
%   OUT = GETEXPORTFRAMENAME(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:45:43 $
if ~isempty(this.DataHandler)
    exportFrameName = this.DataHandler.getExportFrameName;
else
    exportFrameName = '';
end

% [EOF]

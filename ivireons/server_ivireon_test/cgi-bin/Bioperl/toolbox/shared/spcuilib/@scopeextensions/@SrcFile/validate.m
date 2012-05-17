function [success, exception] = validate(hDlg)
%VALIDATE Validate settings of SrcFile extension properties dialog
%  Arguments:
%      hDlg: handle to DDG dialog
%   success: boolean status, 0=fail, 1=accept
%    errMsg: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/06/11 16:05:53 $

success = true;
exception = [];

% No real validation, just normalization of specified path:
%  - Last connect file opened is a path, and must end with filesep char
%
val = hDlg.getWidgetValue('source_Files_LastConnectFileOpened');
if ~isempty(val)
    % Remove leading/trailing space
    val = strtrim(val);
    % Add filesep char at end of path string
    if val(end) ~= filesep
        val = [val filesep];
        hDlg.setWidgetValue('source_Files_LastConnectFileOpened',val);
    end
end

% [EOF]

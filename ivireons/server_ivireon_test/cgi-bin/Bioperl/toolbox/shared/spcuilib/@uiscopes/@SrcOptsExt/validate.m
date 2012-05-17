function [success, exception] = validate(hDlg)
%VALIDATE Validate settings of SrcOptsExt extension properties dialog
%  Arguments:
%      hDlg: handle to DDG dialog
%   success: boolean status, 0=fail, 1=accept
%    errMsg: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/07/23 18:44:27 $

success   = true;
exception = MException.empty;

% Check RecentSourcesListLength
if hDlg.getSource.Config.PropertyDb.findProp('ShowRecentSources').Value
    len = str2double( ...
        hDlg.getWidgetValue( ...
        'RecentSourcesListLength') );
    success = (len==fix(len)) && (len>=1) && (len<=9);
    if ~success
        exception = MException(generatemsgid('InvalidNumEntries'), ...
            'Recent Sources List must have from 1 to 9 entries.');
    end
end

% [EOF]

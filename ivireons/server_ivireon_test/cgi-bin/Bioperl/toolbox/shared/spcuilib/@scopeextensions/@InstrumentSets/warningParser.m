function [category, summary, details] = warningParser(this, warnString, warnID) %#ok<INUSL>
%WARNINGPARSER Parse warnings for use in the MessageLog

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 19:33:07 $

category = 'ISets';

switch warnID
    case {'Spcuilib:scopes:EmptyISet', ...
            'Spcuilib:scopes:OldISet', ...
            'Spcuilib:scopes:NoSerializableScopes'}
        summary = DAStudio.message([warnID 'Summary']);
        details = warnString;
    otherwise
        summary = warnString;
        details = '';
end

% [EOF]

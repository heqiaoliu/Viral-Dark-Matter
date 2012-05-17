function cacheDialogBorderServices(dp)
% Cache DialogBorder services needed when DPVerticalPanel is locked and
% unlocked.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:32 $

% Query DialogBorder services to see which are available.
%
% We record which services are available once during caching.
% These are the same with every dialog registered, since we use the
% same DialogBorder factory for all dialogs registered.

db = makeDialogBorder(dp);  % make a dummy DialogBorder
desiredSvcs = dp.DialogBorderServiceNamesDesired;
actualSvcs = {};
Ndesired = numel(desiredSvcs);
for i=1:Ndesired
    if hasService(db,desiredSvcs{i})
        actualSvcs = [actualSvcs desiredSvcs{i}]; %#ok<AGROW>
    end
end

% Store list of actual service names.
% intersect() may sort these as it wishes (such as alpha-order)
[dp.DialogBorderServiceNamesActual,iDesired] = intersect( ...
    desiredSvcs,actualSvcs);

% Compute intersection with Desired enable values
dp.DialogBorderServiceUnlockedActual = ...
    dp.DialogBorderServiceUnlockedDesired(iDesired);

dp.DialogBorderServiceLockedActual = ...
    dp.DialogBorderServiceLockedDesired(iDesired);

function matchIdx = iptcheckprefname(prefName, allNames)
% IPTCHECKPREFNAME Checks the preference name passed to IPTSETPREF and
%     IPTGETPREF.
%     It errors if there are no matches or if the preference name is
%     ambiguous.  It will also warn if an obsolete preference name is
%     used.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/08/20 22:56:14 $

replacedPref = false;
obsoletePref = false;

matchIdx = [];
actualPrefName = prefName;
len = length(prefName);
for k = 1:length(allNames)
    tmpName = allNames{k};
    if ~isempty(tmpName{1}) && strncmpi(prefName, tmpName{1}, len)
        % matches a valid preference
        matchIdx = [matchIdx, k]; %#ok<AGROW>
        actualPrefName = tmpName{1};
    elseif (length(tmpName)==2) && strncmpi(prefName, tmpName{2}, len)
        % matches an obsoleted preference
        matchIdx = [matchIdx, k]; %#ok<AGROW>
        if isempty(tmpName{1})
            obsoletePref = true;
        else
            replacedPref = true;
        end
        actualPrefName = tmpName{2};
    end
end

% handle unknown/ambiguous preferences
if (isempty(matchIdx))
    eid = sprintf('Images:%s:unknownPreference',mfilename);
    msg = sprintf('Unknown Image Processing Toolbox preference "%s".', ...
        actualPrefName);
    error(eid,'%s',msg);
elseif (length(matchIdx) > 1)
    eid = sprintf('Images:%s:ambiguousPreference',mfilename);
    msg = sprintf('Ambiguous Image Processing Toolbox preference "%s".', ...
        prefName);
    error(eid,'%s',msg);
end

% handle renamed/obsoleted preferences
if replacedPref
    eid = sprintf('Images:%s:obsoletePreference',mfilename);
    msg = sprintf('"%s" is an obsolete preference.  Use %s instead.',...
        actualPrefName, allNames{matchIdx}{1});
    error(eid,'%s',msg);
end
if obsoletePref
    eid = sprintf('Images:%s:obsoletePreference',mfilename);
    msg = sprintf('"%s" is an obsolete preference.',...
        actualPrefName);
    error(eid,'%s',msg);
end

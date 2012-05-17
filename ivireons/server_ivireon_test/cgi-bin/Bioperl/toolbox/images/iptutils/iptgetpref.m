function value = iptgetpref(prefName)
%IPTGETPREF Get value of Image Processing Toolbox preference.
%   PREFS = IPTGETPREF without an input argument returns a structure
%   containing all the Image Processing Toolbox preferences with their
%   current values.  Each field in the structure has the name of an Image
%   Processing Toolbox preference.  See IPTSETPREF for a list.
%
%   VALUE = IPTGETPREF(PREFNAME) returns the value of the Image
%   Processing Toolbox preference specified by the string PREFNAME.  See
%   IPTSETPREF for a complete list of valid preference names.  Preference
%   names are not case-sensitive and can be abbreviated.
%
%   Example
%   -------
%       value = iptgetpref('ImshowAxesVisible')
%
%   See also IMSHOW, IPTSETPREF.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/10/26 14:25:28 $

iptchecknargin(0,1,nargin,mfilename);

% Get IPT factory preference settings
factoryPrefs = iptprefsinfo;
allNames = factoryPrefs(:,1);

if nargin == 0
    % Display all current preference settings
    value = [];
    for k = 1:length(allNames)
        thisField = allNames{k}{1};
        % Skip obsolete preferences
        if ~isempty(thisField)
            value.(thisField) = getpref('ImageProcessing',thisField,...
                factoryPrefs{k,3}{1});
        end
    end
    
else
    % Return specified preferences
    if ~isa(prefName, 'char')
        eid = sprintf('Images:%s:invalidPreferenceName',mfilename);
        msg = 'Preference name must be a string.';
        error(eid,'%s',msg);
    end

    matchIdx = iptcheckprefname(prefName,allNames);    
    preference = allNames{matchIdx}{1};
    value = getpref('ImageProcessing',preference,...
        factoryPrefs{matchIdx, 3}{1});
end

function varargout = iptsetpref(prefName, value)
%IPTSETPREF Set value of Image Processing Toolbox preference.
%   IPTSETPREF(PREFNAME) displays the valid values for the Image
%   Processing Toolbox preference specified by PREFNAME.
%
%   IPTSETPREF(PREFNAME,VALUE) sets the Image Processing Toolbox preference
%   specified by the string PREFNAME to the value specified by VALUE.
%
%   Preference names are case insensitive and can be abbreviated. The
%   default value is enclosed in braces ({}).
%
%   The following preference values can be set:
%
%   'ImshowBorder'        {'loose'} or 'tight'
%
%        Controls whether IMSHOW includes a border around the image in
%        the figure window. Possible values:
%
%        'loose' -- Include a border between the image and the edges of
%                   the figure window, thus leaving room for axes labels,
%                   titles, etc.
%
%        'tight' -- Adjust the figure size so that the image entirely
%                   fills the figure.
%
%        Note: There can still be a border if the image is very small, or
%        if there are other objects besides the image and its axes in the figure.
%
%   'ImshowAxesVisible'   'on' or {'off'}
%
%        Controls whether IMSHOW displays images with the axes box and
%        tick labels. Possible values:
%
%        'on'  -- Include axes box and tick labels.
%
%        'off' -- Do not include axes box and tick labels.
%
%   'ImshowInitialMagnification'   {100}, any numeric value, or 'fit'
%
%        Controls the initial magnification of the image displayed by
%        IMSHOW. Possible values:
%
%        Any numeric value -- IMSHOW interprets numeric values as a
%                             percentage. The default value is 100. One
%                             hundred percent magnification means that
%                             there should be one screen pixel for every
%                             image pixel.
%
%        'fit'             -- Scale the image so that it fits into the
%                             window in its entirety.
%
%        You can override this preference by specifying the
%        'InitialMagnification' parameter when you call IMSHOW, or by
%        calling the TRUESIZE function manually after displaying the image.
%
%   'ImtoolInitialMagnification'   {'adaptive'}, any numeric value, or 'fit
%
%        Controls the initial magnification of the image displayed by
%        IMTOOL. Possible values:
%
%        'adaptive'        -- Display the entire image. If the image is
%                             too large to display on the screen at 100%,
%                             display the image at the largest
%                             magnification that fits on the screen.
%
%        Any numeric value -- IMTOOL interprets numeric values as a
%                             percentage. One hundred percent
%                             magnification means that there should be
%                             one screen pixel for every image pixel.
%
%        'fit'             -- Scale the image so that it fits into the
%                             window in its entirety.
%
%        You can override this preference by specifying the
%        'InitialMagnification' parameter when you call IMTOOL.
%
%   'ImtoolStartWithOverview'    true or {false}
%
%       Controls whether the Overview tool opens by default when viewing
%       an image in the Image Tool (IMTOOL).
%
%       true               -- Open the Overview tool when the Image Tool
%                             starts.
%
%       false              -- Do not open the Overview tool when the Image
%                             Tool starts.
%
%   'UseIPPL'              {true} or false
%
%       Controls whether some toolbox functions use the Intel Performance
%       Primitives Library (IPPL) or not.  Possible values:
%
%       true               -- Enable use of IPPL.
%
%       false              -- Disable use of IPPL.
%
%       NOTE: Setting this preference value has the side effect of clearing
%       all loaded MEX-files.
%
%   Example
%   -------
%       iptsetpref('ImshowBorder', 'tight')
%
%   See also IMSHOW, IPTGETPREF, TRUESIZE.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2008/10/26 14:25:30 $

error(nargchk(1,2,nargin,'struct'));

if (~ischar(prefName))
    eid = sprintf('Images:%s:invalidPropertyName',mfilename);
    msg = 'First input argument must be a property name string';
    error(eid,'%s',msg);
end

% warn if user is calling this from startup.m
stk = dbstack;
for idx = 1:numel(stk)
    if strcmpi(stk(idx).file,'startup.m')
        warn_id = 'Images:iptsetpref:deprecated';
        warning(warn_id,'%s%s%s%s','It is no longer necessary to ',...
            'call IPTSETPREF in your startup.m.  Image Processing ',...
            'Toolbox preferences settings are now persistent between ',...
            'MATLAB sessions.');
    end
end

% Get factory IPT preference settings.
factoryPrefs = iptprefsinfo;
allNames = factoryPrefs(:,1);

matchIdx = iptcheckprefname(prefName,allNames);
preference = allNames{matchIdx}{1};

allowedValues = factoryPrefs{matchIdx, 2};

if nargin == 1
    if nargout == 0
        % Print possible settings
        defaultValue = factoryPrefs{matchIdx, 3};
        if isempty(allowedValues)
            fprintf('The Image Processing Toolbox preference setting\n');
            fprintf('"%s" does not have a fixed set of values.\n',...
                preference);
        else
            fprintf('[');
            for k = 1:length(allowedValues)
                thisValue = allowedValues{k};
                isDefault = ~isempty(defaultValue) & ...
                    isequal(defaultValue{1}, thisValue);
                if (isDefault)
                    fprintf(' {%s} ', num2str(thisValue));
                else
                    fprintf(' %s ', num2str(thisValue));
                end
                notLast = k ~= length(allowedValues);
                if (notLast)
                    fprintf('|');
                end
            end
            fprintf(']\n');
        end
        
    else
        % Return possible values as cell array.
        varargout{1} = factoryPrefs{matchIdx,2};
    end
    
elseif ~isempty(preference)
    % Syntax: IPTSETPREF(PREFNAME,VALUE)
    
    if strcmpi(preference,'ImshowInitialMagnification')
        value = checkInitialMagnification(value,{'fit'},mfilename,...
            'VALUE',2);
        
    elseif strcmpi(preference,'ImtoolInitialMagnification')
        value = checkInitialMagnification(value,{'fit','adaptive'},...
            mfilename,'VALUE',2);
        
    elseif strcmpi(preference,'ImtoolStartWithOverview')
        iptcheckinput(value, {'logical', 'numeric'}, {'scalar'}, ...
            mfilename, 'VALUE',2);
        
    elseif strcmpi(preference,'UseIPPL')
        iptcheckinput(value, {'logical', 'numeric'}, {'scalar'}, ...
            mfilename, 'VALUE',2);
        
        % Clear MEX-files so that the next time an IPPL MEX-file loads
        % it'll check this preference again.
        clear mex
        
        % Force nonlogicals to be logical.
        value = value ~= 0;
        
    else
        value = iptcheckstrs(value,allowedValues,mfilename,'VALUE',2);
        
    end
    
    % save the preference setting
    setpref('ImageProcessing',preference,value);
end

function result = sfpref(prefName,prefVal)
%SFPREF Manages persistent user preferences for Stateflow.
%       SFPREF by itself displays the set of current user preferences.
%       SFPREF('PREFNAME') gets the current value of PREFNAME
%       SFPREF('PREFNAME',PREFVALUE) sets the current value of PREFNAME

%
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.2.2.11 $  $Date: 2010/01/25 23:23:04 $

prefVals = {...
     'hideSymbolWizardAlert', 0 ...
    ,'ignoreUnsafeTransitionActions', 0 ...
    ,'PatternWizardCustomDir', '' ...
    ,'SLSFUnifiedCopyBuffer', 1 ...
    ,'SubchartMappingExtended', 0 ...
    ,'showDeleteUnusedConfGui', 1 ...
    };

availablePrefs = {prefVals{1:2:end}};
defaultValues = {prefVals{2:2:end}};

if(nargin==0)
    currentPrefs = [];
    for i=1:length(availablePrefs)
        try
            if(ispref('Stateflow',availablePrefs{i}))
                val = getpref('Stateflow',availablePrefs{i});
            else
                val = defaultValues{i};
            end
        catch ME %#ok<NASGU>
            val = defaultValues{i};
        end
        currentPrefs.(availablePrefs{i}) = val;
    end
    result = currentPrefs;
else
    found = 0;
    for i=1:length(availablePrefs)
        if(strcmpi(availablePrefs{i},prefName))
            found = 1;
            break;
        end
    end
    if(~found)
        error('Stateflow:UnexpectedError', 'Unknown preference string ''%s'' passed to sfpref',prefName);
    end
    if(nargin==2)
        if(~isequal(class(prefVal),class(defaultValues{i})))
            error('Stateflow:UnexpectedError', 'Preference ''%s'' expects a value of class ''%s''',availablePrefs{i},class(defaultValues{i}));
        end
        try
            setpref('Stateflow',availablePrefs{i},prefVal);
        catch ME %#ok<NASGU>
        end
        
        % This particular feature needs to be available immediately because
        % it is used in prs_main.cpp

        if strcmpi(availablePrefs{i}, 'SLSFUnifiedCopyBuffer')
            sf('feature', availablePrefs{i}, prefVal);
        end
    end
    try
        if(ispref('Stateflow',availablePrefs{i}))
            result = getpref('Stateflow',availablePrefs{i});
        else
            result = defaultValues{i};
        end
    catch ME %#ok<NASGU>
        result = defaultValues{i};
    end
    
end

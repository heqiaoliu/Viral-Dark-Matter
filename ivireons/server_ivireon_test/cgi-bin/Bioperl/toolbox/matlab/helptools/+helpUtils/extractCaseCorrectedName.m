function fixedName = extractCaseCorrectedName(fullName, subName)
    fixedNames = regexpi(fullName, ['\<' regexprep(subName, '\W*', '\\W*') '\>'], 'match');
    if isempty(fixedNames)
        fixedName = '';
    else
        fixedName = regexprep(fixedNames{end}, '[\\/][@+]?', '/');
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/14 14:53:30 $

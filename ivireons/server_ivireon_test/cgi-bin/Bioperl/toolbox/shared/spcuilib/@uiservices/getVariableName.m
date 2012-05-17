function variableName = getVariableName(variableName)
%GETVARIABLENAME Get the variable name with a valid postfix.
%   GETVARIABLENAME(VNAME) Get a variable name based on the string VNAME
%   with a valid postfix.
%
%   % Example #1
%   foo = 1;
%   uiservices.getVariableName('foo')
%
%   % Example #2
%   foo  = 1;
%   foo2 = 2;
%   foo4 = 4;
%   uiservices.getVariableName('foo')

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 22:43:32 $

error(nargchk(1,1,nargin,'struct'));

w = evalin('base', 'whos');

allNames = {w.name};

% If we have a name collision, change the default variable name.
if any(strcmpi(variableName, allNames))

    % Remove all variables that are not at least partial collisions.
    allNames = allNames(strncmpi(variableName, allNames, length(variableName)));

    numPost = getPostFix(variableName, allNames);
    variableName = sprintf('%s%d', variableName, numPost);
end

% -------------------------------------------------------------------------
function numPost = getPostFix(variableName, allNames)

% If there is only 1 variable that has a partial collision, it must be a
% full collision.  Just postfix the number 2.
if length(allNames) == 1;
    numPost = 2;
    return;
end

% Remove the name collision from all of the partial collisions.
allNames = strrep(allNames, variableName, '');

% Convert the rest of the variable names to numbers.  Add 1 for the direct
% name collision.
allNums = [1 str2double(allNames)];

% Remove nans which can be caused by empties or strings
allNums(isnan(allNums)) = [];

if isempty(allNums)
    numPost = 2;
else
    indx = find(diff(allNums) ~= 1, 1);
    if isempty(indx)
        numPost = max(allNums)+1;
    else
        numPost = allNums(indx)+1;
    end
end

% [EOF]

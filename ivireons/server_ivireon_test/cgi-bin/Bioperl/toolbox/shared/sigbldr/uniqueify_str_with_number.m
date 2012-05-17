function newStr = uniqueify_str_with_number(str, ignoreThisIdx, varargin)
%UNIQUEIFY_STR_WITH_NUMBER Logic to determine unique signal and group
%names.

%  Copyright 1984-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $  $Date: 2010/04/05 22:41:05 $

if isempty(ignoreThisIdx)
    ignoreThisIdx = 0;
end

allStrings = varargin;
if ignoreThisIdx > 0
    allStrings(ignoreThisIdx) = [];
end

if ~any(strcmp(str, allStrings))
    newStr = str;
    return;
end

thisRoot = find_ending_numbers(str);
[otherRoots, otherNumbers] = find_ending_numbers(allStrings);

rootMatch = strcmp(thisRoot, otherRoots);
existNumbers = [otherNumbers{rootMatch}];

if isempty(existNumbers)
    newNumber = 1;
else
    newNumber = max(existNumbers) + 1;
end

newStr = [thisRoot{1} num2str(newNumber)];
end
% Subfunctions
function [roots, numbers] = find_ending_numbers(str)

if ~iscell(str)
    str = {str};
end

digitInd = regexp(str, '\d+$');

cnt = length(str);
roots = cell(cnt, 1);
numbers = cell(cnt, 1);

for idx = 1:cnt
    if isempty(digitInd{idx})
        roots{idx} = str{idx};
    else
        roots{idx} = str{idx}(1:(digitInd{idx} - 1));
        numbers{idx} = str2double(str{idx}(digitInd{idx}:end));
    end
end
end
% end Subfunctions
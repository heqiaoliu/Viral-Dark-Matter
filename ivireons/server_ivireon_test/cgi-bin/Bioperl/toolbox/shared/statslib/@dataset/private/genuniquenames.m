function [names,wereModified] = genuniquenames(names,startLoc)
%GENUNIQUENAMES Construct unique names from a list of existing names.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:05 $

wereModified = false;

if nargin < 2, startLoc = 1; end

% Uniqueify the names
numPreceedDups = zeros(length(names),1);
for i = startLoc:length(names)
    name = names{i};
    
    % Calc number of dups within the candidates
    numPreceedDups(i) = length(find(strcmp(name,names(1:i-1))));

    % See if unique candidate is indeed unique - if not up the
    % numPreceedDups
    if numPreceedDups(i)>0 
        wereModified = true;
        uniqueName = appendNumToName(name, numPreceedDups(i));
        while any(strcmp(uniqueName, names))
            numPreceedDups(i) = numPreceedDups(i) + 1;
            uniqueName = appendNumToName(name, numPreceedDups(i));
        end

        % Replace the candidate with the unique string.
        names{i} = uniqueName;
    end
end


%-----------------------------------------------------------------------------
% Append the unique number to name
function uniqueName = appendNumToName(name, num)
numStr = sprintf('_%d',num);
uniqueName = [name numStr];
if length(uniqueName) > namelengthmax
    uniqueName = [uniqueName(1:namelengthmax-length(numStr)) numStr];
end

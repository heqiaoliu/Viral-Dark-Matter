function [names, values] = pCreateEnvironmentVariableArrays(local, origNames, values) %#ok<INUSL>
; %#ok Undocumented

%  Copyright 2006-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $    $Date: 2009/10/12 17:27:44 $


% Get the names to add from the environment
env = dct_psfcns('environ');
% Find everything in the environment from the beginning of the line
% up to the first = sign
namesToAdd  = regexp(env, '^.*?(?==)', 'match', 'once');
% The values are the rest
valuesToAdd = regexp(env, '(?<==).*$', 'match', 'once');

% Always convert to columns for the java end
names = origNames(:);
values = values(:);
numToAdd = numel(namesToAdd);
% Do something if there is anything to add
if (numToAdd > 0)
    % First remove anything that would override the existing values
    [namesToAdd, index] = setdiff(namesToAdd, names);
    valuesToAdd = valuesToAdd(index);
    % Append to the existing variables
    names = [names ; namesToAdd(:)];
    values = [values ; valuesToAdd(:)];
end

% Finally, trim anything that we don't need by comparing current values with
% those seen by Java. Skip past those names that we know were in origNames,
% since we always want to send those.
keep = true( 1, length( names ) );
for ii=(length(origNames)+1):length( names )
    if isequal( values{ii}, char( java.lang.System.getenv( names{ii} ) ) )
        keep( ii ) = false;
    end
end
names  = names( keep );
values = values( keep );

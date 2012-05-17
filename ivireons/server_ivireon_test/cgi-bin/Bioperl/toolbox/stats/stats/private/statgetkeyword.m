function [selected,locs] = statgetkeyword(inputs,kwds,multok,argname,eid)
%STATGETKEYWORD Select from a finite set of choices

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:30:13 $

% Check input arguments
error(nargchk(5,5,nargin,'struct'));
if ~(ischar(inputs) || iscellstr(inputs))
    if multok
        error(eid,...
           'Invalid %s argument, must be a character array or cell array of strings.',...
           argname);
    else
        error(eid,'Invalid %s argument, must be a character string.',argname);
    end
end

% Convert to standard form for convenience
if ischar(inputs)
    inputs = cellstr(inputs);
else
    inputs = inputs(:);
end
if ischar(kwds)
    kwds = cellstr(kwds);
end

% Process each input value
n = length(inputs);
selected = cell(n,1);
locs = zeros(n,1);

if n==0
    error(eid,'Missing value for the %s argument.',argname);
elseif n>1 && ~multok
    error(eid,'Single values required for the %s argument.',argname);
end

for j=1:n
    txt = lower(inputs{j});
    rows = strmatch(txt,kwds);
    if isempty(rows)
        error(eid,'Invalid value "%s" for %s argument.',inputs{j},argname);
    elseif ~isscalar(rows)
        k = strmatch(txt,kwds(rows),'exact');
        if isscalar(k)
            rows = rows(k);
        else  % presumably this is empty unless the kwds input had repeats
            error(eid,'Ambiguous value "%s" for %s argument.',...
                  inputs{j},argname);
        end
    end
    selected{j} = kwds{rows};
    locs(j) = rows;
end

if ~multok
    selected = selected{1};
end

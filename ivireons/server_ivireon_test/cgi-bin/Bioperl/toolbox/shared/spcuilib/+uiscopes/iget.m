function h = iget(varargin)
%IGET     Get the current instrumentation set.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/27 19:53:45 $

% Get all open scopes.
hAll = uiscopes.find(varargin{:});

instNumbers = get(hAll, 'InstanceNumber');
if iscell(instNumbers)
    instNumbers = [instNumbers{:}];
    [instNumbers, indx] = sort(instNumbers);
    hAll = hAll(indx);    
end

% Loop over each scope and get its state.
h = cell(1, length(hAll));
for indx = 1:length(hAll)
    if isSerializable(hAll(indx).ScopeCfg) && ...
            ~isempty(hAll(indx).DataSource) && ...
            isSerializable(hAll(indx).DataSource)
        h{indx} = getState(hAll(indx));
    end
end

h = [h{:}];

% [EOF]

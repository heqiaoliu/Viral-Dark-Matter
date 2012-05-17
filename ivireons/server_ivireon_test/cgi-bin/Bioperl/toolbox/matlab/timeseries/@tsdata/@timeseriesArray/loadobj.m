function h = loadobj(s)

% Place holder for obsolete @timeseries classes

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/02 20:10:58 $

h = tsdata.timeseriesArray;
if isstruct(s)
    if ~isfield(s,'Data') % Loaded @timeseriesArray may be empty
        s.Data = [];
    end
    if ~isfield(s,'GridFirst') % Loaded @timeseriesArray may be empty
        s.GridFirst = true;
    end
    h.LoadedData = s;
else
    h = s;
end

function charts = charts_in(objectId)

% Copyright 2003-2006 The MathWorks, Inc.

charts = [];

if(~isempty(sf('get',objectId,'chart.id')))
   charts = objectId;
elseif(~isempty(sf('get',objectId,'machine.id')))
   charts = sf('get',objectId,'machine.charts');
end

% [EOF]

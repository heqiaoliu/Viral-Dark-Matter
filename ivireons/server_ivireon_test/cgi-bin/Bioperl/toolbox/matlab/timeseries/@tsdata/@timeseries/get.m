function Value = get(ts,Property)

% Copyright 2006-2008 The MathWorks, Inc.

% GET(TS,'Property') or GET(TS,{'Prop1','Prop2',...})
CharProp = ischar(Property);
if CharProp,
  Property = {Property};
elseif ~iscellstr(Property)
  error('timeseries:get:invPropName',...
      'Property name must be a string or a cell vector of strings.')
end

% Loop over each queried property 
Nq = numel(Property); 
Value = cell(1,Nq);
for i=1:Nq,
  % Find match for k-th property name and get corresponding value
  % RE: a) Must include all properties to detect multiple hits
  %     b) Limit comparison to first 7 chars (because of iodelaymatrix)
  try 
     Value{i} = ts.tsValue.(Property{i});
  catch me
     rethrow(me)
  end
end

% Strip cell header if PROPERTY was a string
if CharProp,
  Value = Value{1};
end







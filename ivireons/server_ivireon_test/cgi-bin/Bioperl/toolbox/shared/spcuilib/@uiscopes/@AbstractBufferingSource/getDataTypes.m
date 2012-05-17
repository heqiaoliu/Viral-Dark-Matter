function dataTypes = getDataTypes(this, index)
%GETDATATYPES Get the dataTypes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:40 $

dataTypes = get(this, 'DataTypes');
if isempty(dataTypes)
    dataTypes = {''};
end
if nargin > 1
    dataTypes = dataTypes{index};
end

% [EOF]

function dataTypes = getDataTypes(this, index)
%GETDATATYPES Get the dataTypes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:48 $

dataTypes = class(this.DataHandler.getFrameData);

if nargin < 2
    dataTypes = {dataTypes};
end

% [EOF]

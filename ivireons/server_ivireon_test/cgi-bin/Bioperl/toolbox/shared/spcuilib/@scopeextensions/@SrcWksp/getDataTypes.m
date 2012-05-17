function dataTypes = getDataTypes(this, ~)
%GETDATATYPES Get the dataTypes for the inputs.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:59 $

userData = this.DataHandler.UserData;
if isstruct(userData)
    dataTypes = class(userData(1).cdata);
else
    dataTypes = class(userData);
end

if nargin < 2
    dataTypes = {dataTypes};
end

% [EOF]

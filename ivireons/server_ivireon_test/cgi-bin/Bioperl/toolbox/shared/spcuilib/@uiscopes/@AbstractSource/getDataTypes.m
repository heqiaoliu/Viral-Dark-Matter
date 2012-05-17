function dataTypes = getDataTypes(this, ~)
%GETDATATYPES Get the dataTypes.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:57 $

% Return double as default for all ports.  Subclasses can overload this to
% change the behavior.
dataTypes = 'double';

if nargin < 2
    dataTypes = repmat({dataTypes}, getNumInputs(this), 1);
end    

% [EOF]

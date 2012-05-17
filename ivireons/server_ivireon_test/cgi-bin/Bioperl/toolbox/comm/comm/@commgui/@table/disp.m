function disp(this)
%DISP     Display this object

%	@commgui\@table
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:24 $

% Define the fields to be displayed in order
fieldNames = {'Type', ...
    'Parent', ...
    'ColumnLabels', ...
    'TableData'};

excludedFieldNames = {};

baseDisp(this, fieldNames, excludedFieldNames);

%-------------------------------------------------------------------------------
% [EOF]

function l = addNewDataListener(this, varargin)
%ADDNEWDATALISTENER Add a listener to the new Data event.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:44:23 $

if isempty(this.DataSource)
    l = [];
else
    l = addNewDataListener(this.DataSource, varargin{:});
end

% [EOF]

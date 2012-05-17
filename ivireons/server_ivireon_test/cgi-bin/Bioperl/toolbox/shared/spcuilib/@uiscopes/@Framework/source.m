function s = source(this)
%SOURCE   Get command-line args for scope instance.
%   SOURCE(M) returns the command-line arguments that can
%   be used to re-instantiate the current data source, as
%   a cell-vector.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/09/15 20:47:28 $

% Get current source arguments
if ~isempty(this.DataSource)
    s = this.DataSource.commandLineArgs;
else
    s = {};
end

% [EOF]

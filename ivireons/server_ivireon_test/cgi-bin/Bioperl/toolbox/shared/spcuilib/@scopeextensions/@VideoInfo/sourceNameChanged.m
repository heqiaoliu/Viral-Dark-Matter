function sourceNameChanged(this, update)
%SOURCENAMECHANGED Update the source name.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/09 19:33:27 $

this.SourceLocation = this.hAppInst.DataSource.Name;

% Force an update if it is not specifically suppressed with a false flag.
if (nargin < 2 || update) && ~isempty(this.Dialog)
    refresh(this.Dialog);
end

% [EOF]

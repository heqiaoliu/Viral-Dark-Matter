function sourceNameChanged(this,update)
% SOURCENAMECHANGED Update the source name
    
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/11/16 22:33:49 $   

dSrc = this.hAppInst.DataSource;
if ~isempty(dSrc)
  this.SourceLocation = dSrc.getSourceName;
end

% Force an update if it is not specifically suppressed with a false flag.
if (nargin < 2 || update) && ~isempty(this.Dialog)
    refresh(this.Dialog);
end

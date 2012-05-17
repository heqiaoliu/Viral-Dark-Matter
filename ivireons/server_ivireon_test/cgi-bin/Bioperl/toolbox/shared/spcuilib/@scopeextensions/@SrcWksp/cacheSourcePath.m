function cacheSourcePath(this)
%CACHESRCPATH Extracts the path information from the ScopeCLI object.
   
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:42:41 $

this.SrcPath = '';
if ~isempty(this.ScopeCLI) && ~isempty(this.ScopeCLI.ArgNames)
    % extract the path from ArgNames and cache it in the SrcPath property.
    idx = findstr(this.ScopeCLI.ArgNames{1},':');
    if ~isempty(idx)
        this.SrcPath = this.ScopeCLI.ArgNames{1}(1:idx(end)-1);
        % retain just the variable name in the ArgNames field.
        this.ScopeCLI.ArgNames{1} = this.ScopeCLI.ArgNames{1}(idx(end)+1:end);
    end
end
       
% [EOF]

function s = getDependsStr(this)
%getDependsStr Return formatted string indicating all dependencies
%   of this extension.
%
% .Depends is a cell-string containing zero or more names of extensions
% upon which this extension depends, i.e., {'type:name','type:name', ...}

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/04/09 19:04:32 $

de = this.Depends;

% Force into cell array if just a string
if isempty(de)
    s = '';
else
    % Form string concatenation of each cell
    s = sprintf('%s, ', de{:});
    s(end-1:end) = [];
end

% [EOF]

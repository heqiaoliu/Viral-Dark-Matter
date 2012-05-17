function s = message(this)
%MESSAGE Return formatted violation message.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:38 $

% Format message string:
% '    Type (Constraint:Details)'
% Ex:
% '    General (EnableAll:)'
%
% Note: uses 4 leading spaces, so that display works
%       well with ExtTypeConstraintViolationDb display method.

if isempty(this.Details)
    s = sprintf('    %s, %s\n', ...
        this.Type, ...
        this.Constraint);
else
    s = sprintf('    Type:%s, Constraint:%s (%s)\n', ...
        this.Type, ...
        this.Constraint, ...
        this.Details);
end

% [EOF]

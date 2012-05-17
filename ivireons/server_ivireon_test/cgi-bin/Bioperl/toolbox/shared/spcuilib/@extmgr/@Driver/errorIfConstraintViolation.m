function errorIfConstraintViolation(this)
%ERRORIFCONSTRAINTVIOLATION Throw error if there is a constraint violation.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:37:27 $

vdb = extmgr.TypeConstraintViolationDb;

% Visit each registered RegisterType to check for constraint violations
iterator.visitImmediateChildren(this.RegisterDb.RegisterTypeDb, ...
    @(h) vdb.add(h.Constraint.findViolations(this.ConfigDb)));

if ~isEmpty(vdb)
    % Rethrow extension type-constraint violations in current config set as
    % an error.
    error(generatemsgid('ConstraintViolation'), ...
        'Extension constraints violated in current configuration.\n%s', ...
        messages(vdb));
end

% [EOF]

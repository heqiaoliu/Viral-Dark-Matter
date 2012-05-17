function this = TypeConstraintViolationDb(v)
%TypeConstraintViolationDb Database of type-constraint violations.
%  TypeConstraintViolationDb constructs a new database object containing
%  extension type-constraint violations.
%
%  TypeConstraintViolationDb(V1,V2,...) automatically adds
%  TypeConstraintViolation objects to the database.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:40 $

this = extmgr.TypeConstraintViolationDb;
if nargin>0
    add(this, v);
end

% [EOF]

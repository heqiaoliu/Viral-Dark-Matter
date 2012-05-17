function this = TypeConstraintViolation(theType,theConstraint,theDetails)
%ExtTypeConstraintViolation Extension type constraint violation object.
%  ExtTypeConstraintViolation(Type,Constraint,Details) creates a violation
%  object that specifies a constraint violated by configuration.  Details
%  is an optional string describing the specific violation.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:51 $

error(nargchk(2,3,nargin,'struct'));
this = extmgr.TypeConstraintViolation;
this.Type = theType;
this.Constraint = theConstraint;
if nargin>2
    this.Details = theDetails;
end

% [EOF]

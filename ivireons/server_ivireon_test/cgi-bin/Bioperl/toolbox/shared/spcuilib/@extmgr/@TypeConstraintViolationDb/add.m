function add(this, arg, varargin)
%ADD Add violations to database.
%  ADD(hVDb,V) adds TypeConstraintViolation object V to violations
%  database.  V is copied before being added.
%
%  ADD(hVDb,hVDb2) adds all violations in database hVDb2 to database by
%  making copies of each violation and adding them individually to hVDb.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:53 $

if isa(arg,'extmgr.TypeConstraintViolation')
    % Add copy of a single violation
    connect(copy(arg),this,'up');
    
elseif isa(arg,'extmgr.TypeConstraintViolationDb')
    % Add a database of violations (arg is hVDb2)
    iterator.visitImmediateChildren(arg, @(v) add(this,v) );
    
elseif ischar(arg)
    connect(extmgr.TypeConstraintViolation(arg, varargin{:}), this, 'up');
else
    error(generatemsgid('InvalidChild'), ...
        'Unsupported input argument of class %s', class(arg));
end

% [EOF]

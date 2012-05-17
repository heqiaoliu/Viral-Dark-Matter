function add(this, varargin)
%ADD      Add an object to the database.
%   ADD(H, NEWCHILD) Add the NEWCHILD object to the database H.
%
%   ADD(H, INPUT1, INPUT2, etc.) construct an object from the values of
%   INPUT1, INPUT2, etc.  Use the output of getChildClass as the
%   constructor for the child object.  This will only work when
%   getChildClass returns a concrete class.
%
%   See also extmgr.Database/REMOVE.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:37:23 $

% Do nothing if we are passed nothing.
if nargin < 2
    return;
end

cClass = getChildClass(this);

% If the first argument is not of the child class, try to construct one
% from the inputs.
if ~isa(varargin{1}, cClass)
    varargin = {feval(cClass, varargin{:})};
end

for indx = 1:numel(varargin)
    hNewChild = varargin{indx};
    
    if ~isa(hNewChild, cClass)
        error(generatemsgid('InvalidChild'), ...
            'Argument must be an object of class %s', cClass);
    end

    % Connect child to database.  Change the up of the child to avoid
    % interfering with the database's down.
    connect(hNewChild, this, 'up');
end

% [EOF]

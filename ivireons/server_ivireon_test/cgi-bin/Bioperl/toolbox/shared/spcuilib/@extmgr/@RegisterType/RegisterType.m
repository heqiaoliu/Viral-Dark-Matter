function this = RegisterType(type,constraint,order)
%RegisterType Extension registration type object.
%  RegisterType(Type) creates an extension registration type object with
%  defaults for all properties such as type constraint and instantiation
%  order.
%
% Properties:
%
% Constraint
%   This constrains the ability of a user to enable named extensions of a
%   given extension type.  The constraint imposed on an extension type
%   limits how many extensions of a given type can be enabled and/or
%   disabled.
%
%  EnableAny:
%    Any number of extensions can be enabled of this type.
%  EnableAll:
%    All extensions of this type will be enabled, with no ability to
%    disable any of the extensions of this type.
%  EnableOne:
%    Exactly one extension of this type must be enabled at one time, thus
%    providing "mutually exclusive" behavior to the extension enables.
%  EnableAtLeastOne:
%    At least one extension of this type must be enabled at all times.
%
%  Order Real number indicating order of loading and position in
%  configuration editor dialog.  Lower numbers mean load/display earlier.

% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/11/18 02:13:47 $

error(nargchk(1, 3, nargin, 'struct'));
this = extmgr.RegisterType;
this.Type = type;

if nargin < 2
    
    % If we are not passed an enable constraint, create the default
    % EnableAny object.
    constraint = extmgr.EnableAny(type);
elseif ischar(constraint) || isa(constraint, 'function_handle')
    
    % If we are passed a string for the constraint, assume it is the
    % constructor and create it.
    constraint = feval(constraint, type);
end

this.Constraint = constraint;
if nargin > 2
    this.Order = order;
end

% These subfunctions allow callers to specify shorter constraint strings,
% e.g. 'EnableAll' or 'EnableOne' instead of 'extmgr.EnableAll' or
% 'extmgr.EnableOne'.  We don't want to just assuming that strings without
% '.' are class names in the extmgr package because people may want to
% write their own EnableConstraint objects without needing a package.

% -------------------------------------------------------------------------
function h = EnableAll(varargin) %#ok

h = extmgr.EnableAll(varargin{:});

% -------------------------------------------------------------------------
function h = EnableAny(varargin) %#ok

h = extmgr.EnableAny(varargin{:});

% -------------------------------------------------------------------------
function h = EnableOne(varargin) %#ok

h = extmgr.EnableOne(varargin{:});

% -------------------------------------------------------------------------
function h = EnableAtLeastOne(varargin) %#ok

h = extmgr.EnableAtLeastOne(varargin{:});

% -------------------------------------------------------------------------
function h = EnableZeroOrOne(varargin) %#ok

h = extmgr.EnableZeroOrOne(varargin{:});

% [EOF]

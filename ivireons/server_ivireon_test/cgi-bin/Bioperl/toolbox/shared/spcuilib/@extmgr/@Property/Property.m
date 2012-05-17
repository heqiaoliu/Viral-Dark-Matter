function this = Property(varargin)
%Property Extension property object.
%  Property(Name,Type,Value,Status) creates a property and value
%  for an extension property configuration.  Property must be
%  a string, and Value can be any valid MATLAB data type.
%  Status  may be one of 'Active', 'Default', or 'Obsolete'.
%  Type must be a valid UDD data type, and match the type of the
%  Value argument.
%
%  Property(Name,Type,Value) assumes Status='Active'.
%  Note that Name and Value must be specified.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/09/09 21:29:03 $

% NOTE:
% Status denotes the meaning of property/value settings.
%
%  Active:
%     value is set via user interaction or from a stored (serialized)
%     configuration; the value may or may not be equal to the default
%     property value.  Only Active config properties support user
%     interaction via a dialog, etc.
%  Default:
%     value represents the default value as found in the extension
%     registration at the time it was read.  Default is never written
%     to a serialized file - it is always changed to Config in that case.
%     Defaults can only appear in memory and only come from extension
%     registration.
%  Obsolete:
%     property is from extension registration, and represents an obsolete
%     property; value is to be disregarded.  Property should no longer be
%     serialized, and Config automatically invokes method to upgrade/remove
%
%     The default status is "Active", since Default and Obsolete are
%     less frequent and not to be accidentally used.

% NOTE:
% Dynamic property usage in object
%    This object creates a dynamic property during object construction.
%    Name, Type, and Value must be specified in the constructor, as these
%    are used to create the dynamic property on the object with property
%    name as specified in 'Name'.
%
%    - Issue 1
%    .Name must contain a valid UDD property name, and the user could
%    violate this.
%    - Issue 2
%    .Name might conflict with the property names used for Name, Type, and
%    Value, and Status.

this = extmgr.Property;

if nargin > 0
    init(this, varargin{:});
end

% [EOF]

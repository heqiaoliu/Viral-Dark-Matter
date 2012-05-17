function this = Register(type, name, class, desc, varargin)
%Register Constructor for extension registration object.
%   REGISTER(Type,Name,Class) constructs an extension registration object
%   with unique type/name strings.
%
%   See RegisterDb for a description of the extension definition database
%   that holds instances of the Register class.
%
%   Creating a Register entry does NOT trigger license checkout on the
%   plug-in.  It does NOT instantiate the extension until the plug-in is
%   ENABLED.  Then it does a lightweight instance via enableChanged()
%   method.
%
%   Type: extension type.  This can be any string, but is usually a "soft"
%         enumeration defined by the application
%
%   Name: short string describing the extension, suitable for use on the 
%         preferences tab
%
%   Class: a string describing "package.class" that implements the
%         extension
%
%   Description: longer, single-line string describing the extension

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/08/03 21:37:38 $

% NOTE:
%   We're relying on a user-specified plug-in registration to pass info to
%   this instance, so expect to carefully check all arguments. Instances of
%   Register are usually created by the RegisterDb::add() method, which
%   itself is directly called by the user registration file.
%
%   A non-empty .errormsg signifies an error to the caller

% Caller checks and posts the error to message log
if nargin < 3
    error('MATLAB:nargchk:tooFewInputs', ...
        ['Too few arguments specified in call to ADD()\n', ...
        'The following arguments must be specified:\n', ...
        '  ext.add(''Type'', ''Name'', ''Class'')\n']);
end

% We add varargin to the function prototype just so this message can be
% provided to our extension authors.
if nargin > 4
    error('MATLAB:nargchk:tooManyInputs', ...
        ['Too many arguments specified in call to ADD()\n', ...
        'The following arguments may be specified:\n', ...
        '  ext.add(''Type'', ''Name'', ''Class'', ''Description'')\n', ...
        'All other parameters must be set as property values.\n']);
end

% Instantiate object
this = extmgr.Register;

% Required args;
this.Type  = type;
this.Name  = name;
this.Class = class;

% Optional args:
if nargin>3
    this.Description = desc;
end

% [EOF]

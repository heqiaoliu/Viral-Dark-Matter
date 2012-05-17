function this = RegisterTypeDb(varargin)
%RegisterTypeDb Database of extension registration types.
%  RegisterTypeDb constructs a new database object containing extension types
%  registered by an extension.  Not all extension types need to be
%  registered.  Only those that have a non-standard constraint associated
%  with them, such as SelectOne or SelectAll, must be registered.
%
%  When an extension registers a type, it might add the following example
%  line to its scopext.m registration file:
%     h = ext.addtype('TypeName');
%     h.Constraint = 'SelectOne';
%  This adds an RegisterType object to the RegisterTypeDb database.
%
%  RegisterTypeDb(T1,T2,...) automatically adds RegisterType objects
%  to the extension type database.
%
%  If a duplicate type is added to the database, the old one is removed.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:24 $

this = extmgr.RegisterTypeDb;

% Extension type objects T1,T2,T3... specified
add(this, varargin{:});

% [EOF]

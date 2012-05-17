function schema
% Defines properties for @tooleditor adapter class

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:15 $

% RE: @tooleditor adapts @tooldlg editor to @constreditor interface

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'tooleditor',findclass(pk,'constreditor'));

% Public
schema.prop(c, 'Container', 'mxArray');    % Current constraint container
schema.prop(c, 'Dialog', 'mxArray');       % @tooldlg handle

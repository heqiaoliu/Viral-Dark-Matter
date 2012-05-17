function schema
%SCHEMA  Class definition for @datasource (abstract data source).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:28:54 $

% Register class
pkg = findpackage('wrfc');
c = schema.class(pkg, 'datasource');

% Class attributes
schema.prop(c, 'Name', 'string');        % Source name

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

% Class events
schema.event(c, 'SourceChanged');

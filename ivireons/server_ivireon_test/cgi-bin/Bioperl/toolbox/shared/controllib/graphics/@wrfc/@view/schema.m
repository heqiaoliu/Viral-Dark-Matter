function schema
%SCHEMA  Definition of @view interface (abstract view container).

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:48 $

% Register class 
pkg = findpackage('wrfc');
c = schema.class(pkg, 'view');

% Public attributes
schema.prop(c, 'AxesGrid', 'handle');      % @axesgrid container
schema.prop(c, 'Parent', 'handle');        % Parent view object (used, e.g., for resp. char.)
p = schema.prop(c, 'Visible', 'on/off');   % View visibility
p.FactoryValue = 'on';                    

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off');

function schema
%SCHEMA  Defines properties for @timeview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:39 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('wavepack'), 'timeview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array');  % Handles of HG lines (matrix)
p = schema.prop(c, 'Style', 'string');     % Discrete time system curve style [stairs|stem]
p.FactoryValue = 'stairs';
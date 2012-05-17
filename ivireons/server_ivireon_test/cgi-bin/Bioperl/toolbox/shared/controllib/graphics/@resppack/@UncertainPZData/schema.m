function schema
%  SCHEMA  Defines properties for @UncertainPZData class

%  Author(s): Craig Buhr
%  Revised:
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:25 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'UncertainPZData', superclass);


schema.prop(c, 'Data',   'MATLAB array');       % Poles 
schema.prop(c, 'Poles',   'MATLAB array');       % Poles 
schema.prop(c, 'Zeros',   'MATLAB array');       % Zeros
schema.prop(c, 'Ts',      'MATLAB array');       % Sampling Time




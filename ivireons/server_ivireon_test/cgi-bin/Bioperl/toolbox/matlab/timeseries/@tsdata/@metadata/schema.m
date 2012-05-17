function schema
%SCHEMA Defines properties for METADATA class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2007/12/10 21:40:48 $

% Register class 
c = schema.class(findpackage('tsdata'),'metadata');
c.Handle = 'off';

% Public properties
schema.prop(c,'Units','string'); 
schema.prop(c,'Scale','MATLAB array');  
schema.prop(c,'Interpolation','handle');
schema.prop(c,'Offset','MATLAB array'); 
p = schema.prop(c,'GridFirst','bool');
p.FactoryValue = true;
 



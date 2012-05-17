function schema
%SCHEMA  Defines properties for @TunedZPKSnapshot class

%  Copyright 1986-2005 The MathWorks, Inc. 
%  $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:46:23 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'TunedMaskSnapshot', findclass(pkg, 'TunedBlockSnapshot'));
c.Handle = 'off'; 


% Temp workaround
p = schema.prop(c, 'Value','MATLAB array');
p.FactoryValue = zpk(1);
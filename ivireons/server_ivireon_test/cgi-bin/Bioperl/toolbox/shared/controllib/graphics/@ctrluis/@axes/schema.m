function schema
% Defines properties for @axes class (single axes)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:41 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axes',findclass(pk,'axesgroup'));

% Properties
p = schema.prop(c,'LimitStack','MATLAB array');    % Limit stack
p.FactoryValue = struct('Limits',zeros(0,4),'Index',0);
function schema
% Defines properties for @piecewisedata class

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:43 $

pk = findpackage('srorequirement');

% Register class 
c = schema.class(pk,'piecewisedata',findclass(pk,'requirementdata'));

%Data
schema.prop(c,'Linked','MATLAB array');             % Flags indicating how neighbours are joined in x & y axis
p = schema.prop(c,'SelectedEdge','MATLAB array');   % Edge closest to last button down
p.FactoryValue = 1;
p = schema.prop(c,'OpenEnd','MATLAB array');        %Extend left/right end to infinity 
p.FactoryValue = [false, false];

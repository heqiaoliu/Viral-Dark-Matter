function schema
% Defines properties for @LumpedPlant class (monolithic augmented plant model)

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/06/20 20:00:46 $
pk = findpackage('sisodata');
c = schema.class(pk,'LumpedPlant',findclass(pk,'plant'));

% Private properties
% ZPK representation of plant model (for faster freq. resp. computation)
p = schema.prop(c,'Pfr','MATLAB array');  
p.AccessFlags.PublicGet = 'off';
%p.AccessFlags.PublicSet = 'off';

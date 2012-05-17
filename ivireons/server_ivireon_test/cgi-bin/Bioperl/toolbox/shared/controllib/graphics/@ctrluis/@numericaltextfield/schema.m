function schema
% Defines properties for @numericaltextfield class 

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:48 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'numericaltextfield',findclass(pk,'axesgroup'));

% Private properties
p = schema.prop(c,'hJava','MATLAB array');      %handle to javacomponent MJNumericalTextField object
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'hContainer','handle');       %handle to uipanel containing the MJNumericalTextField object
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'UserData','MATLAB array');   %place holder for user data
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';





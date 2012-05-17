function schema
%SCHEMA  Defines properties for @TunedZPKSnapshot class

%  Copyright 1986-2005 The MathWorks, Inc. 
%  $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:39:47 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'TunedZPKSnapshot', findclass(pkg, 'TunedBlockSnapshot'));
c.Handle = 'off'; 

%% Public Properties
p = schema.prop(c,'Value','MATLAB array');    % Property for user to set value


%% Private Properties
p = schema.prop(c, 'Constraints','MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'ZPK2ParFcn','MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Tunable part of the TunedZPK is stored in Gain and PZGroup properties
p = schema.prop(c,'ZPKGain','double');       % ZPK Gain of the tunable part
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'PZGroup','MATLAB array');   % Pole/zero groups information
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'Variable','string');    % Variable used to specify model data
p.Visible = 'off';

% Fixed part of the TunedZPK
p = schema.prop(c,'FixedDynamics','MATLAB array');    % Fixed dynamics
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'InitialValue','MATLAB array');    % Property for user to set value
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

function schema
%SCHEMA  Schema for TunedBlockSnapshot abstract class.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:39:26 $

% Register class 
c = schema.class(findpackage('sisodata'),'TunedBlockSnapshot');
c.Handle = 'off'; 

%% Public properties
schema.prop(c,'Name','string');        % Model name
schema.prop(c,'Description','string'); % Model Description


%% Private properties
p = schema.prop(c,'Ts','double');             % Sample time 
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'TsOrig','double');         % Original Sample time
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'Parameters','MATLAB array');   % Parameters of the parameterization
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'Par2ZpkFcn','MATLAB array'); % function handle to par2zpk function
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'C2DMethod','MATLAB array'); % function for converting sample time
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'D2CMethod','MATLAB array'); % function for converting sample time
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c,'AuxData','MATLAB array'); % property to store the port IO [outport inport]
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
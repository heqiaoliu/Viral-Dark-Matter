function schema
% Defines properties for @TunedLoopSnapshot class (user-visible).
% 
%   Snapshot of TunedLoop, used by @design class.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:39:34 $
c = schema.class(findpackage('sisodata'),'TunedLoopSnapshot');
c.Handle = 'off'; 

%% Public Properties

% Model name
schema.prop(c,'Name','string');    
% Description

schema.prop(c,'Description','string');

% Editors used to tune this components
schema.prop(c,'View','MATLAB array');   


%% Private Properties
% Feedback or feedforward?
p = schema.prop(c,'Feedback','bool');    
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% Loop status
p = schema.prop(c,'LoopConfig','MATLAB array');    
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% TunedLFT of Loop
p = schema.prop(c,'TunedLFTBlocks','MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c,'TunedLFTSSData','MATLAB array'); 
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c,'TunedFactors','MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c,'ClosedLoopIOs','MATLAB array');   
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';


  

% Version
p = schema.prop(c,'Version','double');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 1.0;



function schema
%SCHEMA  Schema for TunedLoop class, tunable SISO loop.

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2010/03/26 17:22:10 $

% Register class 
c = schema.class(findpackage('sisodata'),'TunedLoop');

% Public properties
schema.prop(c,'Name','string');        % Model name
schema.prop(c,'Description','string'); % Model description 
schema.prop(c,'Identifier','string');  % Model identifier 

% Is it a feedback loop? (true for feedback loops)
schema.prop(c,'Feedback','bool');

schema.prop(c,'ContainsDelay','MATLAB array');
schema.prop(c,'ContainsFRD','MATLAB array');

p=schema.prop(c,'TunedLFTSSData','MATLAB array');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(c,'Nominal','double');
p.FactoryValue = 1;

schema.prop(c,'TunedFactors','handle vector');% Vector of TunedZPK in series

% LFT struct for information of indirectly tuned elements.
% TunedLFT = lft(IC,Blocks)
% TunedLFT.Blocks TunedBlocks
%         .IC     SSData for lower lft
%         .ssdata cache
%         .zpkdata cache
%         .frddata cache
p = schema.prop(c,'TunedLFT','MATLAB array');  
p.AccessFlags.PublicSet = 'off';

schema.prop(c,'Ts','double');               % Sample time 

schema.prop(c,'ModelData','MATLAB array');   % State-space or FRD data (cached)

schema.prop(c,'LoopConfig','MATLAB array'); % TunedLoop Configuration info

% Defines I/O pair for overlay response in graphical editor (e.g. in a
% prefilter design
schema.prop(c,'ClosedLoopIO','MATLAB array'); 

% Stability margins (struct) 
% struct('Gm',Gm,'Pm',Pm,'Wcg',Wcg,'Wcp',Wcp,'Stable',isStable);
schema.prop(c,'Margins','MATLAB array');  


schema.prop(c,'Listeners','MATLAB array');  % Listeners


% Tuned Loop has changed configuration (i.e. loop openings)
schema.event(c,'OpenLoopConfigChange');      


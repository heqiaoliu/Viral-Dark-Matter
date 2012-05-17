function schema
% Defines properties for @loopdata class 
% (data structure for fixed-configuration SISO design tools)

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $ $Date: 2006/06/20 20:01:26 $
c = schema.class(findpackage('sisodata'),'loopdata');

% Public properties
% Control system name
p = schema.prop(c,'Name','string');
p.FactoryValue = 'untitled';
% Control system Identifier
p = schema.prop(c,'Identifier','string');

% Design history (vector of @design objects)
p = schema.prop(c,'History','MATLAB array'); 
% External inputs (names)
schema.prop(c,'Input','string vector');
% Performance outputs (names)
schema.prop(c,'Output','string vector');
% I/O maps of interest for closed-loop analysis
% (vector of @looptransfer objects)
schema.prop(c,'LoopView','MATLAB array');
% Augmented plant (@plant object)
schema.prop(c,'Plant','handle');
% Sample time
schema.prop(c,'Ts','double');               
% Tunable components or compensators (@TunedBlock vector)
schema.prop(c,'C','handle vector');
% Characteristics of each SISO loop (@TunedLoop vector)
schema.prop(c,'L','handle vector');

% Event data
p = schema.prop(c,'EventData','MATLAB array'); 
p.FactoryValue = struct(...
   'Phase',[],...      % what edit phase (for dynamic edits) [init|finish]
   'Scope',[],...      % what data is modified?              [all|pz|gain]
   'Component',[],...  % what tuned model is affected (index into this.C)?
   'Editor',[],...     % what editor is being used
   'Extra',[]);        % additional data

% Private properties
% Closed loop model (@ssdata object)
p = schema.prop(c,'ClosedLoop','MATLAB array');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
% Listeners
p = schema.prop(c,'Listeners','MATLAB array');  % Listeners
p.FactoryValue = struct('Fixed',[],'Tuned',[]);
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% Events
% First data import (fired by importdata)
schema.event(c,'FirstImport');        
% Change in loop configuration or MIMO plant model (fired automatically)
% RE: To update config views, related menus, and editors' dependency lists
schema.event(c,'ConfigChanged');
% Change in loop data (for external clients only, fired automatically)
schema.event(c,'LoopDataChanged');
% Dynamic gain update (start/finish)
schema.event(c,'MoveGain');   
% Dynamic pole/zero update (start/finish)
schema.event(c,'MovePZ');
% Algebraic loop in some feedback loop
schema.event(c,'SingularLoop');      

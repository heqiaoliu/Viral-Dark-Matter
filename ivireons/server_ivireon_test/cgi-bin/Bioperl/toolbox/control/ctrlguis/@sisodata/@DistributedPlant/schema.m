function schema
% Defines properties for @DistributedPlant class (structured
% loop configurations)

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/06/20 20:00:42 $
pk = findpackage('sisodata');
c = schema.class(pk,'DistributedPlant',findclass(pk,'plant'));

% Public properties
% Interconnection matrix
schema.prop(c,'Connectivity','MATLAB array');  
% Fixed components (vector of @fixedmodel objects)
schema.prop(c,'G','handle vector');         
% Feedback signs (one per feedback junction)
schema.prop(c,'LoopSign','MATLAB array');  
% Open/closed status of each feedback junction (for closed-loop simulation only)
p = schema.prop(c,'LoopStatus','MATLAB array'); % true=closed, false=open
p.SetFunction = @LocalClearPsim;

% Private properties
% Augmented plant for closed-loop simulation and analysis, taking
% LoopStatus into consideration (@ssdata object)
p = schema.prop(c,'Psim','MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

%--------------- Local Functions ---------------

function v = LocalClearPsim(this,v)
% Clear Psim 
clearPsim(this)
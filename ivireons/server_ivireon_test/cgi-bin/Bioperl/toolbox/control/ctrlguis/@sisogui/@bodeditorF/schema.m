function schema
%SCHEMA  Schema for the PreFilter Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2005/12/22 17:42:28 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'bodeditorF',findclass(sisopack,'bodeditor'));

% Editor-specific properties
% Closed-loop view (struct with fields Description, Input, Output)
% RE: Input and Output are scalar indices relative to LoopData.ClosedLoop
schema.prop(c,'ClosedLoopView','MATLAB array');      
schema.prop(c,'ClosedLoopFrequency','MATLAB array');  % Frequency vector for closed-loop model
schema.prop(c,'ClosedLoopMagnitude','MATLAB array');  % Closed-loop mag vector
% Magnitude is for the normalized closed loop for configs 1,2
schema.prop(c,'ClosedLoopPhase','MATLAB array');      % Closed-loop phase vector 

% Plot attributes
p = schema.prop(c,'ClosedLoopVisible','on/off');  % Visibility of closed loop
set(p,'AccessFlags.Init','on','FactoryValue','on');



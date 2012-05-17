function schema
% Defines properties for @design class.
% 
%   @design is a snapshot of the current loop data. This data structure
%   is used for saving designs, initializing the SISO Tool, and handling
%   import/export operations.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2010/05/10 16:58:57 $
c = schema.class(findpackage('sisodata'),'design');
c.Handle = 'off'; 

%% Public Properties
% Control system name
schema.prop(c,'Name','string');     

% Configuration number
p = schema.prop(c,'Configuration','double'); 
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

% Description
p = schema.prop(c,'Description','string');
p.FactoryValue = 'Design snapshot.';

% Feedback signs
schema.prop(c,'FeedbackSign','MATLAB array');

% External inputs (names)
schema.prop(c,'Input','string vector');

% Performance outputs (names)
schema.prop(c,'Output','string vector');


%% Private Properties
% Analysis views (vector of loop transfer functions)
p = schema.prop(c,'LoopView','MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Names of fixed components
p = schema.prop(c,'Fixed','string vector'); 
p.AccessFlags.PublicSet = 'off';
% Names of tuned components
p = schema.prop(c,'Tuned','string vector');
p.AccessFlags.PublicSet = 'off';
% Names of Open Loops
p = schema.prop(c,'Loops','string vector');
p.AccessFlags.PublicSet = 'off';

% Index into Nominal Model
p = schema.prop(c,'NominalModelIndex','double');
p.Visible = 'off';
p.FactoryValue = 1;

p = schema.prop(c,'Version','double');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0.0;

% Version 1.0 is for R2006a
p = schema.prop(c,'Version','double');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0.0;

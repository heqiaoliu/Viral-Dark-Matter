function schema
% Defines properties for @labelstyle class (style for axes labels).

%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:44 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'labelstyle');

% Properties
schema.prop(c,'Color','MATLAB array');    % Axes color
schema.prop(c,'FontAngle','string');      % Font angle
schema.prop(c,'FontSize','double');       % Font size
schema.prop(c,'FontWeight','string');     % Font weight
schema.prop(c,'Interpreter','string');    % Interpreter
p = schema.prop(c,'Location','string');   % Location [left|right|top|bottom]
p.FactoryValue = 'left';

% Style update function
schema.prop(c,'UpdateFcn','MATLAB callback');

% Listeners
p = schema.prop(c,'Listeners','handle vector');        % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');  

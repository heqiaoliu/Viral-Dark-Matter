function schema
% Defines properties for @axesstyle class

%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:10 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axesstyle');

% Properties
schema.prop(c,'Color','MATLAB array');    % Axes color
schema.prop(c,'FontAngle','string');      % Font angle
schema.prop(c,'FontSize','double');       % Font size
schema.prop(c,'FontWeight','string');     % Font weight
schema.prop(c,'XColor','MATLAB array');   % X axis color
schema.prop(c,'YColor','MATLAB array');   % Y axis color

% Style update function
schema.prop(c,'UpdateFcn','MATLAB callback');

% Listeners
p = schema.prop(c,'Listeners','handle vector');        % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');  

function schema
% Defines properties for @session class (SISO Tool session)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:43:48 $
c = schema.class(findpackage('sisogui'),'session');

% Version history
% 1.0 -> R12.1 (struct)
% 2.0 -> R13   (struct)
% 3.0 -> R14   (class)

% Design history (first = current)
% vector of sisodata.design objects
schema.prop(c,'Designs','handle vector');     
% History (text)
schema.prop(c,'History','string vector');     
% Saved preferences (struct)
schema.prop(c,'Preferences','MATLAB array'); 
% Saved editor settings (struct array)
schema.prop(c,'EditorSettings','MATLAB array');
% Saved viewer settings (struct array)
schema.prop(c,'ViewerSettings','MATLAB array');

% Private properties
% Version
p = schema.prop(c,'Version','double');  
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 3.0;

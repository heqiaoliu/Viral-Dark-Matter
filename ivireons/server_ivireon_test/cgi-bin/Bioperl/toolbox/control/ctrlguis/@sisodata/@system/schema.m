function schema
% Defines properties for @system class (user visible).
% 
%   Snapshot of fixed model, used by @design class.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2010/02/08 22:29:54 $
c = schema.class(findpackage('sisodata'),'system');
c.Handle = 'off';

% Model name
schema.prop(c,'Name','string');     
% Model value (LTI or double)
p = schema.prop(c,'Value','MATLAB array');
p.SetFunction = @LocalSetValue;
% Variable is the name of the variable used to specify the
% component value (e.g., Gservo)
p = schema.prop(c,'Variable','string');     
p.Visible = 'off';

% Version
p = schema.prop(c,'Version','double');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 1.0;


function v = LocalSetValue(this,v)
% Checks incoming model value
if ~(isa(v,'double') || isa(v,'dynamicsys') || isa(v,'DynamicSystem') || isa(v,'idmodel'))
   ctrlMsgUtils.error('Control:compDesignTask:FixedModelData')
end

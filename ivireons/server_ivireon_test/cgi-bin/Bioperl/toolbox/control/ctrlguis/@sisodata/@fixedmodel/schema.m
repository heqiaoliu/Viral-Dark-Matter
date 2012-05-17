function schema
%SCHEMA  Schema for fixed model class.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $ $Date: 2009/04/21 03:07:25 $
c = schema.class(findpackage('sisodata'),'fixedmodel');

% Define properties
schema.prop(c,'Name','string');         % Model name
schema.prop(c,'Description','string');  % Model description (e.g., 'sensor')
schema.prop(c,'Identifier','string');   % Model identifier (wrt loop config)
schema.prop(c,'Variable','string');     % Variable used to specify model data

schema.prop(c,'Model','MATLAB array');  % Original @lti model
schema.prop(c,'ModelData','MATLAB array'); % @ssdata or @frddata representation


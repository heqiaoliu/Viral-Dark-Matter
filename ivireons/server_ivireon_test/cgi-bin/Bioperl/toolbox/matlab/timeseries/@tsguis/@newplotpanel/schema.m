function schema
% Defines properties for @newplotpanel class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:15:49 $


%% Register class (subclass)
c = schema.class(findpackage('tsguis'),'newplotpanel');

%% Public properties
schema.prop(c,'Handles','MATLAB array');

%% Main panel
schema.prop(c,'Panel','MATLAB array');

%% Parent node
schema.prop(c,'Node','MATLAB array');


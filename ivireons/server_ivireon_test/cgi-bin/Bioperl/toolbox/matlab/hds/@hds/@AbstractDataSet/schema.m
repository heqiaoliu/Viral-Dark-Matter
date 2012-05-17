function schema
% Defines properties for @AbstractDataSet class.
%
%   Base class for HDS data set family.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/12/22 18:13:35 $

% Register class 
c = schema.class(findpackage('hds'),'AbstractDataSet');

% Private properties
% Description of the grid of independent variables
p = schema.prop(c,'Grid_','MATLAB array'); 
p.FactoryValue = struct('Length',cell(1,0),'Variable',[]);
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

% Data for each node variable (independent and dependent)
p = schema.prop(c,'Data_','handle vector');      % @ValueArray objects
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

% Data set parent
p = schema.prop(c,'Parent_','handle');           % @AbstractDataSet
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% Linked data sets
p = schema.prop(c,'Children_','handle vector');  % @LinkArray objects
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

% Cached data (optimization)
p = schema.prop(c,'Cache_','MATLAB array');    % struct
p.FactoryValue = struct('Variables',[],'Links',[],'GridDim',zeros(0,1));
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';

% Version
p = schema.prop(c,'Version','double'); 
p.FactoryValue = 0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

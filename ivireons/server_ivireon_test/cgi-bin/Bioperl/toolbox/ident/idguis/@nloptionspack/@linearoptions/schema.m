function schema
% SCHEMA  Defines properties for linearoptions class

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/05/18 05:06:40 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'linearoptions');

% handle to a wavenet object
p = schema.prop(c,'Object','MATLAB array');
p.FactoryValue = linear;

schema.prop(c,'NlarxPanel','handle'); % handle to owning UDD panel object
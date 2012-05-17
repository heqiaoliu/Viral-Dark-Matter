function schema
%SCHEMA Defines timeseriesArray data storage class

%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:54:24 $

% Register class 
p = findpackage('tsdata');
c = schema.class(p,'timeseriesSrcArray',findclass(findpackage('hds'),'VirtualArray'));

% Public properties
schema.prop(c,'Metadata','handle'); 
% schema.prop(c,'Events','MATLAB array');
% schema.prop(c,'metaVariable','handle'); 

% The ReadOnly flag is used by the @tscollection to disable user
% writes to the time vector of a member @timeseries
p = schema.prop(c,'ReadOnly','on/off'); 
p.FactoryValue = 'off';

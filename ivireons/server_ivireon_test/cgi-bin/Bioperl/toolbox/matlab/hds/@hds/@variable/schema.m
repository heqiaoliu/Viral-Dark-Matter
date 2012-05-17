function schema
% Defines properties for @variable class (data set variable).

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/12/22 18:15:00 $

% Register class 
c = schema.class(findpackage('hds'),'variable');

% Public properties
p = schema.prop(c,'Name','string'); % Variable name
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'off';

% Version
p = schema.prop(c,'Version','double'); 
p.FactoryValue = 0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

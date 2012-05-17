function schema
% SCHEMA  Defines properties for @OkCancelHelp class

% Author(s): Alec Stothert
% Revised:
% Copyright 1986-2004 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:22 $

%Package
pk = findpackage('ctrluis');

%Class
c = schema.class(pk,'OkCancelHelp');

%Properties
%Button dimensions
p = schema.prop(c,'bWidth','double');
p.FactoryValue = 10;
p = schema.prop(c,'bHeight','double');
p.FactoryValue = 1.5;
p = schema.prop(c,'bgap','double');
p.FactoryValue = 1;
%Button group position
p = schema.prop(c,'X0','double');
p.FactoryValue = 0;
p = schema.prop(c,'Y0','double');
p.FactoryValue = 0;
%Button handles, read only
p = schema.prop(c,'hOK','double');
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'hCancel','double');
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'hHelp','double');
p.AccessFlags.PublicSet = 'off';
%Button group sizes, read only
p = schema.prop(c,'Height','double');
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'Width','double');
p.AccessFlags.PublicSet = 'off';

% Object container handle, private
p = schema.prop(c, 'hC', 'double');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

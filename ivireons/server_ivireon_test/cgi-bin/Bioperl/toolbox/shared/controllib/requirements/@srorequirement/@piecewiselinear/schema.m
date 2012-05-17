function schema
%SCHEMA for piecewiselinear class

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:58 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'piecewiselinear',findclass(pk,'requirement'));

%Native Properties
p = schema.prop(c,'isPlotted','bool');
p.FactoryValue = false;
if (isempty(findtype('SRO_orientation_type')))
   schema.EnumType('SRO_orientation_type',{'horizontal','vertical','both'});
end
p = schema.prop(c,'Orientation','SRO_orientation_type');     
p.FactoryValue = 'horizontal';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

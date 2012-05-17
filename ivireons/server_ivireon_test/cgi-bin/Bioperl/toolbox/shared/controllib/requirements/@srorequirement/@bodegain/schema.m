function schema 
% SCHEMA  bodegain object schema
%
 
% Author(s): A. Stothert 06-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:33 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'bodegain',findclass(pk,'piecewiselinear'));

%Native Properties
p = schema.prop(c,'isSemiLogX','bool');
p.FactoryValue = true;

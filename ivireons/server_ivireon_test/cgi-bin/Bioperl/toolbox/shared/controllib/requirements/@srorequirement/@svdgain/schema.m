function schema 
% SCHEMA  svdgain object schema
%
 
% Author(s): A. Stothert 06-Apr-2005
%   Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:17 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'svdgain',findclass(pk,'piecewiselinear'));

%Native Properties
p = schema.prop(c,'isSemiLogX','bool');
p.FactoryValue = true;

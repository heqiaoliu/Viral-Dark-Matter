function schema
%SCHEMA for timeresponse class

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:25 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'timeresponse',findclass(pk,'piecewiselinear'));

%Native Properties



function schema
%  SCHEMA  Defines properties for @FreqStabilityMarginData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:31 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'AllStabilityMarginData');

% Register class
c = schema.class(pkg, 'MinStabilityMarginData', supclass);

% RE: data units are 
%     frequency: rad/sec 
%     magnitude: abs
%     phase: degrees
function schema
%SCHEMA  Defines properties for @pzdata class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:54 $
supclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'hsvdata', supclass);

% Public attributes - Data
schema.prop(c, 'HSV',   'MATLAB array');       % HSV
function schema
%SCHEMA  Defines properties for @sigmaplot class

%  Author(s): Bora Eryilmaz
%  Revised  : Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:10 $

% Register class (subclass)
pkg = findpackage('resppack');
c = schema.class(pkg, 'sigmaplot', findclass(pkg, 'respplot'));

% Private properties
% Global frequency focus (rad/sec, default = [])
p = schema.prop(c, 'FreqFocus', 'MATLAB array');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
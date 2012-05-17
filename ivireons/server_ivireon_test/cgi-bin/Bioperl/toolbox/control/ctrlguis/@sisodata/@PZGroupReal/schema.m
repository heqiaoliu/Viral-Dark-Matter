function schema
%SCHEMA  Schema for real pole/zero group class

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:46:42 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'PZGroupReal', findclass(pkg, 'pzgroup'));

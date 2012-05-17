function schema
%SCHEMA  Defines properties for @annotatedconstr class

%   Author(s): A. Stothert
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:18 $

pk = findpackage('plotconstr');

% Register class 
schema.class(pk, 'annotatedconstr', findclass(pk, 'designconstr'));


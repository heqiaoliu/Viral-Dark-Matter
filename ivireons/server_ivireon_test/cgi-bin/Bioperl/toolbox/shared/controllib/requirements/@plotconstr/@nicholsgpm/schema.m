function schema
%SCHEMA  Defines properties for @nicholsphase margin class

%   Author(s): Alec Stothert
%   Revised:
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:12 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk, 'nicholsgpm', findclass(pk, 'designconstr'));

% Editor data
schema.prop(c, 'Origin', 'mxArray');      % Display origin (in deg)




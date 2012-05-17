function schema
% Defines properties for @MetaData class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2005/12/22 18:14:49 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'metadata',findclass(p,'AbstractMetaData'));

schema.prop(c,'Units','string');       % units

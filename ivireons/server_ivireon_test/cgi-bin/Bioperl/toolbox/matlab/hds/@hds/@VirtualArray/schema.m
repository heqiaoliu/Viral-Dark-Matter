function schema
% Defines properties for @VirtualArray class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:14:34 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'VirtualArray',findclass(p,'ValueArray'));

% Public properties
schema.prop(c,'Storage','MATLAB array');  % Array container


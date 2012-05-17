function schema
% Defines properties for @BasicArray class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/12/22 18:13:56 $

% Register class 
p = findpackage('hds');
c = schema.class(p,'BasicArray',findclass(p,'ValueArray'));

% Public properties
p = schema.prop(c,'Data','MATLAB array');       % Array value
p.AccessFlags.AbortSet = 'off';   % perf optimization


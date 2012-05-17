function schema
% Defines properties for @constreditor superclass

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:36 $

% Register class 
c = schema.class(findpackage('plotconstr'), 'constreditor');

% Interface methods: show, isVisible
function schema
%SCHEMA  Defines properties for @nicholsview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:18 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'nicholsview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array');  % Handles of HG lines
schema.prop(c, 'UnwrapPhase', 'on/off');   % Phase wrapping
p = schema.prop(c, 'ComparePhase', 'MATLAB array');   % Phase matching
p.FactoryValue = struct(...
   'Enable', 'off',...
   'Freq', 0, ...
   'Phase', 0); 
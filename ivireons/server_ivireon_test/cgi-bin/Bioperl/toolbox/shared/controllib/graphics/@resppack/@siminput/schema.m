function schema
%SCHEMA  Defines properties for @siminput class

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:25 $
superclass = findclass(findpackage('wavepack'), 'waveform');
c = schema.class(findpackage('resppack'), 'siminput', superclass);

schema.prop(c, 'ChannelName', 'string vector');   % input channel names
p = schema.prop(c, 'Interpolation', 'string');    % interpolation method
p.FactoryValue = 'auto';

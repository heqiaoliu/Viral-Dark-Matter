function schema
%SCHEMA  Class definition for @wavechar (waveform characteristics).

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:44 $
superclass = findclass(findpackage('wrfc'),'dataview');
c = schema.class(findpackage('wavepack'), 'wavechar', superclass);

schema.prop(c,'Identifier','string');   % Constraint type identifier
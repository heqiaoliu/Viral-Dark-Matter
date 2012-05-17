function schema
%SCHEMA  Define properties for @optimmessenger class.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/10/02 18:50:54 $

c = schema.class(findpackage('nlutilspack'),'optimmessenger');

schema.event(c,'optiminfo'); 
% event data: @idguievent is used to package iterinfo

p = schema.prop(c,'Stop','bool');
p.FactoryValue = false;

p = schema.prop(c,'Enabled','bool');
p.FactoryValue = true;

function schema
%SCHEMA  Define properties for @messenger class.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:22:00 $

c = schema.class(findpackage('nlutilspack'),'messenger');

schema.prop(c,'MessengerID','string');

schema.event(c,'identguichange'); %data/model change 

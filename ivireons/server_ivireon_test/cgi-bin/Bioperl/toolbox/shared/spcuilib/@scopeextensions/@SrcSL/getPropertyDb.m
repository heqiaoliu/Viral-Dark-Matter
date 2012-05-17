function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:42:15 $

hPropDb = uiscopes.AbstractBufferingSource.getPropertyDb;

% Flag to determine if we should open the simulink model when loading the
% source if it isn't already open.  When this is false, if the model isn't
% open the source cannot be activate.
hPropDb.add('OpenSimulinkModel', 'bool', true);

if isempty(findtype('SimulinkProbingSupport'))
    schema.EnumType('SimulinkProbingSupport', ...
        {'SignalLines', 'SignalLinesOrBlocks'});
end

% Flag to determine if clicking on blocks while in floating mode adds them
% to the scope or if they are ignored.
hPropDb.add('ProbingSupport', 'SimulinkProbingSupport');

% [EOF]

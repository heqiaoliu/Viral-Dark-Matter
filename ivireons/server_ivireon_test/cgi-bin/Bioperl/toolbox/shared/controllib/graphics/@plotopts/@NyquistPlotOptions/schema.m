function schema
%SCHEMA  Definition of @NyquistPlotOptions 
% Options for @NyquistPlot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:40 $

% Register class 
pkg = findpackage('plotopts');
superclass = findclass(pkg, 'RespPlotOptions');
c = schema.class(pkg, 'NyquistPlotOptions', superclass);

% Public attributes
p = schema.prop(c, 'FreqUnits', 'String'); 
p.setfunction = {@LocalSetFreqUnits};
p.FactoryValue = 'rad/sec';

p = schema.prop(c, 'MagUnits', 'String'); 
p.setfunction = {@LocalSetMagUnits};
p.FactoryValue = 'dB';

p = schema.prop(c, 'PhaseUnits', 'String');
p.setfunction = {@LocalSetPhaseUnits};
p.FactoryValue = 'deg';

p = schema.prop(c, 'ShowFullContour', 'on/off'); 
p.FactoryValue = 'on';



%----------------------LOCAL SET FUCTIONS---------------------------------%

% ------------------------------------------------------------------------%
% Function: LocalSetFreqUnits
% Purpose:  Error handling of setting Frequency Units property
% ------------------------------------------------------------------------%
function valueStored = LocalSetFreqUnits(this, ProposedValue)

if iscell(ProposedValue)
    ProposedValue  = ProposedValue{1};
end
if any(strcmpi(ProposedValue,{'Hz','rad/sec', 'rad/s'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:FreqUnitsProperty1','FreqUnits')
end

% ------------------------------------------------------------------------%
% Function: LocalSetPhaseUnits
% Purpose:  Error handling of setting Phase Units property
% ------------------------------------------------------------------------%
function valueStored = LocalSetPhaseUnits(this, ProposedValue)

if iscell(ProposedValue)
    ProposedValue  = ProposedValue{1};
end
if any(strcmpi(ProposedValue,{'rad','deg'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:PhaseUnitsProperty1','PhaseUnits')
end

% ------------------------------------------------------------------------%
% Function: LocalSetMagUnits
% Purpose:  Error handling of setting Magnitude Units property
% ------------------------------------------------------------------------%
function valueStored = LocalSetMagUnits(this, ProposedValue)

if iscell(ProposedValue)
    ProposedValue  = ProposedValue{1};
end
if any(strcmpi(ProposedValue,{'dB','abs'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:MagUnitsProperty1','MagUnits')
end


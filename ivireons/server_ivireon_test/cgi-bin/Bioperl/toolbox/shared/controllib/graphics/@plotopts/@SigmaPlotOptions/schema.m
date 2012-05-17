function schema
%SCHEMA  Definition of @SigmaPlotOptions 
% Options for @SigmaPlot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:18:04 $

% Register class 
pkg = findpackage('plotopts');
superclass = findclass(pkg, 'RespPlotOptions');
c = schema.class(pkg, 'SigmaPlotOptions', superclass);

% Public attributes
p = schema.prop(c, 'FreqUnits', 'MATLAB array'); 
p.setfunction = {@LocalSetFreqUnits};
p.FactoryValue = 'rad/sec';

p = schema.prop(c, 'FreqScale', 'MATLAB array'); 
p.setfunction = {@LocalSetScale, 'FreqScale'};
p.FactoryValue = 'log';

p = schema.prop(c, 'MagUnits', 'MATLAB array'); 
p.setfunction = {@LocalSetMagUnits};
p.FactoryValue = 'dB';

p = schema.prop(c, 'MagScale', 'MATLAB array'); 
p.setfunction = {@LocalSetScale, 'MagScale'};
p.FactoryValue = 'linear';



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
% Function: LocalSetScale
% Purpose:  Error handling of setting Freq and Mag scale property
% ------------------------------------------------------------------------%
function valueStored = LocalSetScale(this, ProposedValue, Prop)

if iscell(ProposedValue)
    ProposedValue  = ProposedValue{1};
end
if any(strcmpi(ProposedValue,{'log','linear'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:ScaleProperty1',Prop)
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
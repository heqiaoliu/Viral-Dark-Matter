function schema
%SCHEMA  Definition of @NicholsPlotOptions 
% Options for @respplot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:34 $

% Register class 
pkg = findpackage('plotopts');
superclass = findclass(pkg, 'RespPlotOptions');
c = schema.class(pkg, 'NicholsPlotOptions', superclass);

% Public attributes
p = schema.prop(c, 'FreqUnits', 'String');  
p.setfunction = {@LocalSetFreqUnits};
p.FactoryValue = 'rad/sec';

p = schema.prop(c, 'MagLowerLimMode', 'MATLAB array');
p.setfunction = {@LocalSetMagLowerLimMode};
p.FactoryValue = 'auto';

p = schema.prop(c, 'MagLowerLim', 'MATLAB array');
p.setfunction = {@LocalSetMagLowerLim};
p.FactoryValue = 0;

p = schema.prop(c, 'PhaseUnits', 'String');
p.setfunction = {@LocalSetPhaseUnits};
p.FactoryValue = 'deg';

p = schema.prop(c, 'PhaseWrapping', 'on/off'); 
p.FactoryValue = 'off';

p = schema.prop(c, 'PhaseMatching', 'on/off');
p.FactoryValue = 'off';

p = schema.prop(c, 'PhaseMatchingFreq', 'MATLAB array');
p.setfunction = {@LocalSetPhaseMatchingFreq};
p.getfunction = {@LocalGetPhaseMatchingFreq};
p.FactoryValue = 0;

p = schema.prop(c, 'PhaseMatchingValue', 'MATLAB array');
p.setfunction = {@LocalSetPhaseMatchingValue};
p.getfunction = {@LocalGetPhaseMatchingValue};
p.FactoryValue = 0;
 
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
if any(strcmpi(ProposedValue,{'deg','rad'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:PhaseUnitsProperty1','PhaseUnits')
end

% ------------------------------------------------------------------------%
% Function: LocalSetMagLowerLim
% Purpose:  Error handling of setting MagLowerLim property
% ------------------------------------------------------------------------%
function valueStored = LocalSetMagLowerLim(this, ProposedValue)
% Note MagLowerLim is stored in dB and -inf is valid
if isnumeric(ProposedValue) && isscalar(ProposedValue) && ...
        isreal(ProposedValue) && (ProposedValue~=inf)
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties07','MagLowerLim')
end

% ------------------------------------------------------------------------%
% Function: LocalSetMagLowerLimMode
% Purpose:  Error handling of setting Mag lower lim mode property
% ------------------------------------------------------------------------%
function valueStored = LocalSetMagLowerLimMode(this, ProposedValue)

if iscell(ProposedValue)
    ProposedValue  = ProposedValue{1};
end
if any(strcmpi(ProposedValue,{'auto','manual'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:LimModeProperty2','MagLowerLimMode')
end

% ------------------------------------------------------------------------%
% Function: LocalSetPhaseMatchingFreq
% Purpose:  Error handling of setting PhaseMatchingFreq property
% ------------------------------------------------------------------------%
function valueStored = LocalSetPhaseMatchingFreq(this, ProposedValue)

% store the value in rad/s units
valueStored = unitconv(ProposedValue,this.FreqUnits,'rad/s');


% ------------------------------------------------------------------------%
% Function: LocalGetPhaseMatchingFreq
% Purpose:  Get PhaseMatchingFreq property
% ------------------------------------------------------------------------%
function valueToCaller = LocalGetPhaseMatchingFreq(this, valueStored)
% note PhaseMatchingFreq is stored in rad/s in the object
valueToCaller = unitconv(valueStored,'rad/s',this.FreqUnits);

% ------------------------------------------------------------------------%
% Function: LocalSetPhaseMatchingValue
% Purpose:  Error handling of setting PhaseMatchingValue property
% ------------------------------------------------------------------------%
function valueStored = LocalSetPhaseMatchingValue(this, ProposedValue)

% store the value in rad units
valueStored = unitconv(ProposedValue,this.PhaseUnits,'rad');


% ------------------------------------------------------------------------%
% Function: LocalGetPhaseMatchingValue
% Purpose:  Get PhaseMatchingValue property
% ------------------------------------------------------------------------%
function valueToCaller = LocalGetPhaseMatchingValue(this, valueStored)
% note PhaseMatchingFreq is stored in rad in the object
valueToCaller = unitconv(valueStored,'rad',this.PhaseUnits);


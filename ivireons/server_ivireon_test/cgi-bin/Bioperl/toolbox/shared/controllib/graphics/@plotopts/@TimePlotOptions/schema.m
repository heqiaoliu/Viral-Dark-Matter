function schema
%SCHEMA  Definition of @TimePlotOptions 
% Options for @timeplot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:18:09 $

% Register class 
pkg = findpackage('plotopts');
superclass = findclass(pkg, 'RespPlotOptions');
c = schema.class(pkg, 'TimePlotOptions', superclass);

% Public attributes
p = schema.prop(c, 'Normalize', 'on/off');  
p.FactoryValue = 'off';

p = schema.prop(c, 'SettleTimeThreshold', 'MATLAB array');  
p.setfunction = {@LocalSetSettleTimeThreshold};
p.FactoryValue = .02;

p = schema.prop(c, 'RiseTimeLimits', 'MATLAB array');
p.setfunction = {@LocalSetRiseTimeLimits};
p.FactoryValue = [.10 .90];



%----------------------LOCAL SET FUCTIONS---------------------------------%

% ------------------------------------------------------------------------%
% Function: LocalSetSettleTimeThreshold
% Purpose:  Error handling of setting SettleTimeThreshold property
% ------------------------------------------------------------------------%
function valueStored = LocalSetSettleTimeThreshold(this, ProposedValue)
if isnumeric(ProposedValue) && isscalar(ProposedValue) && ...
        isreal(ProposedValue) && isfinite(ProposedValue)
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties08')
end

% ------------------------------------------------------------------------%
% Function: LocalSetRiseTimeLimits
% Purpose:  Error handling of setting RiseTimeLimits property
% ------------------------------------------------------------------------%
function valueStored = LocalSetRiseTimeLimits(this, ProposedValue)
if isnumeric(ProposedValue) && all((size(ProposedValue)==[1,2]))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties09')
end
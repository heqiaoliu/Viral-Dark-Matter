function schema
%SCHEMA  Definition of @PZMapOptions 
% Options for @respplot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:45 $

% Register class 
pkg = findpackage('plotopts');
superclass = findclass(pkg, 'RespPlotOptions');
c = schema.class(pkg, 'PZMapOptions', superclass);

% Public attributes
p = schema.prop(c, 'FreqUnits', 'String');      
p.setfunction = {@LocalSetFreqUnits};
p.FactoryValue = 'rad/sec';


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
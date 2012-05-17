function schema
%SCHEMA  Definition of @RespPlotOptions 
% Options for @respplot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:59 $

% Register class 
pkg = findpackage('plotopts');
superclass = findclass(pkg, 'PlotOptions');
c = schema.class(pkg, 'RespPlotOptions', superclass);

% Public attributes
p = schema.prop(c, 'IOGrouping', 'String');      
p.setfunction = {@LocalSetIOGrouping};
p.FactoryValue = 'none';
 
p = schema.prop(c, 'InputLabels', 'MATLAB array'); 
p.setfunction = {@LocalSetIOLabel 'InputLabels'};
p.FactoryValue = struct('FontSize',   8, ...
                        'FontWeight', 'Normal', ...
                        'FontAngle',  'Normal', ...
                        'Color',      [0.4,0.4,0.4], ...
                        'Interpreter', 'tex');

p = schema.prop(c, 'OutputLabels', 'MATLAB array');
p.setfunction = {@LocalSetIOLabel 'OutputLabels'};
p.FactoryValue = struct('FontSize',   8, ...
                        'FontWeight', 'Normal', ...
                        'FontAngle',  'Normal', ...
                        'Color',      [0.4,0.4,0.4], ...
                        'Interpreter', 'tex');

p = schema.prop(c, 'InputVisible', 'MATLAB array');
p.setfunction = {@LocalSetIOVisible 'InputVisible'};
p.FactoryValue = {'on'};

p = schema.prop(c, 'OutputVisible', 'MATLAB array');
p.setfunction = {@LocalSetIOVisible 'OutputVisible'};
p.FactoryValue = {'on'};


%----------------------LOCAL SET FUCTIONS------------------------------

% ------------------------------------------------------------------------%
% Function: LocalSetIOGrouping
% Purpose:  Error handling of setting IOGrouping property
% ------------------------------------------------------------------------%
function valueStored = LocalSetIOGrouping(this, ProposedValue)

valueStored = this.IOGrouping;
if ischar(ProposedValue) && any(strcmpi(ProposedValue, {'none','all','inputs','outputs'}))
    valueStored = ProposedValue;
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties05')
end


% ------------------------------------------------------------------------%
% Function: LocalSetIOLabel
% Purpose:  Error handling of setting IO label property
% ------------------------------------------------------------------------%
function valueStored = LocalSetIOLabel(this, ProposedValue, Prop)

valueStored = this.(Prop);
if isstruct(ProposedValue)
    Fields = fields(ProposedValue);
    for ct = 1:length(Fields)
        switch Fields{ct}
            case 'FontSize'
                valueStored.FontSize = ProposedValue.FontSize;
            case 'FontWeight'
                valueStored.FontWeight = ProposedValue.FontWeight;
            case 'FontAngle'
                valueStored.FontAngle = ProposedValue.FontAngle;
            case 'Color'
                valueStored.Color = ProposedValue.Color;
            case 'Interpreter'
                valueStored.Interpreter = ProposedValue.Interpreter;
            otherwise
                ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties01',Fields{ct},Prop)
        end
    end
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties02',Prop)
end



% ------------------------------------------------------------------------%
% Function: LocalSetIOVisible
% Purpose:  Error handling of setting IO Visibility property
% ------------------------------------------------------------------------%
function valueStored = LocalSetIOVisible(this, ProposedValue, Prop)

if iscell(ProposedValue) && ...
        all(strcmpi(ProposedValue,{'on'}) | strcmpi(ProposedValue,{'off'}))
    valueStored = ProposedValue(:);
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties03',Prop)
end
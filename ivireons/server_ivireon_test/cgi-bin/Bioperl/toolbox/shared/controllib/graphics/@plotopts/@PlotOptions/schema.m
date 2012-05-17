function schema
%SCHEMA  Definition of @PlotOptions 
% Options for @plot

%  Author(s): C. Buhr
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:54 $

% Register class 
pkg = findpackage('plotopts');
c = schema.class(pkg, 'PlotOptions');

p = schema.prop(c, 'Version', 'double');
p.visible = 'off';
p.FactoryValue = 0;


% Public attributes
% Title and Labels
p = schema.prop(c, 'Title', 'MATLAB array');  
p.setfunction = {@LocalSetLabel 'Title'};
p.FactoryValue = struct('String',     '', ...
                        'FontSize',   8, ...
                        'FontWeight', 'Normal', ...
                        'FontAngle',  'Normal', ...
                        'Color',      [0,0,0], ...
                        'Interpreter', 'tex');

p = schema.prop(c, 'XLabel', 'MATLAB array');  
p.setfunction = {@LocalSetLabel 'XLabel'};
p.FactoryValue = struct('String',     '', ...
                        'FontSize',   8, ...
                        'FontWeight', 'Normal', ...
                        'FontAngle',  'Normal', ...
                        'Color',      [0,0,0], ...
                        'Interpreter', 'tex');

p = schema.prop(c, 'YLabel', 'MATLAB array');
p.setfunction = {@LocalSetLabel 'YLabel'};
p.FactoryValue = struct('String',     '', ...
                        'FontSize',   8, ...
                        'FontWeight', 'Normal', ...
                        'FontAngle',  'Normal', ...
                        'Color',      [0,0,0], ...
                        'Interpreter', 'tex');

p = schema.prop(c, 'TickLabel', 'MATLAB array');
p.setfunction = {@LocalSetTickLabel};
p.FactoryValue = struct('FontSize',   8, ...
                        'FontWeight', 'Normal', ...
                        'FontAngle',  'Normal', ...
                        'Color',      [0,0,0]);

% Grid
p = schema.prop(c, 'Grid', 'on/off');   
p.FactoryValue = 'off';  

% Limits and Limit modes
p = schema.prop(c, 'XLim', 'MATLAB array'); 
p.setfunction = {@LocalSetLim, 'XLim'};
p.FactoryValue = {[1 10]};

p = schema.prop(c, 'XLimMode', 'MATLAB array');
p.setfunction = {@LocalSetLimMode};
p.FactoryValue = {'auto'};

p = schema.prop(c, 'YLim', 'MATLAB array');
p.setfunction = {@LocalSetLim, 'YLim'};
p.FactoryValue = {[1 10]};

p = schema.prop(c, 'YLimMode', 'MATLAB array');
p.setfunction = {@LocalSetLimMode};
p.FactoryValue = {'auto'};


%----------------------LOCAL SET FUCTIONS------------------------------

% ------------------------------------------------------------------------%
% Function: LocalSetLabel
% Purpose:  Error handling of setting Title, XLabel, YLabel properties
% ------------------------------------------------------------------------%
function valueStored = LocalSetLabel(this, ProposedValue, Prop)

valueStored = this.(Prop);
if isstruct(ProposedValue)
    Fields = fields(ProposedValue);
    for ct = 1:length(Fields)
        switch Fields{ct}
            case 'String'
                valueStored.String = ProposedValue.String;
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
% Function: LocalSetTickLabel
% Purpose:  Error handling of setting TickLabel property
% ------------------------------------------------------------------------%
function valueStored = LocalSetTickLabel(this, ProposedValue)

valueStored = this.TickLabel;
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
            otherwise
                ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties01',Fields{ct},'TickLabel')
        end
    end
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties02','TickLabel')
end


% ------------------------------------------------------------------------%
% Function: LocalSetLim
% Purpose:  Error handling of setting X and Y limit property
% ------------------------------------------------------------------------%
function valueStored = LocalSetLim(this, ProposedValue, Prop)

if isnumeric(ProposedValue)
    ProposedValue = {ProposedValue};
end
if iscell(ProposedValue) && all(cellfun('size',ProposedValue,2)==2) && ...
        all(cellfun('size',ProposedValue,2)==2)
    for ct = 1:length(ProposedValue)
        if ProposedValue{ct}(2) <= ProposedValue{ct}(1)
            ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties04',Prop)
        end
    end
    valueStored = ProposedValue;
    if strcmpi(Prop(1),'x')
        this.XLimMode = repmat({'manual'},size(this.XLimMode));
    else
        this.YLimMode = repmat({'manual'},size(this.YLimMode));
    end
else
    ctrlMsgUtils.error('Controllib:plots:PlotOptionsProperties04',Prop)
end



% ------------------------------------------------------------------------%
% Function: LocalSetLimMode
% Purpose:  Error handling of setting X and Y limmode property
% ------------------------------------------------------------------------%
function valueStored = LocalSetLimMode(this, ProposedValue, Prop)

if ischar(ProposedValue)
    ProposedValue = {ProposedValue};
end
if iscell(ProposedValue) && ...
        all(strcmpi(ProposedValue,{'auto'}) | strcmpi(ProposedValue,{'manual'}))
    valueStored = ProposedValue;
else
        ctrlMsgUtils.error('Controllib:plots:LimModeProperty1',Prop)
end
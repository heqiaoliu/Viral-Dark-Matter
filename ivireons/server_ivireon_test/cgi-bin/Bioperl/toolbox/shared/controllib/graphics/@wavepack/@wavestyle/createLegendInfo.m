function createLegendInfo(this)
%createLegendInfo  Creates the legend info for the style.
%

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:36 $

LineColors = this.Colors;
LineStyles = this.LineStyles;
Markers = this.Markers;

% Check if Line Colors are fixed across I/Os
if isscalar(LineColors)
    ColorProps = {'Color', LineColors{1}};
else 
    ColorProps = {'Color', [.1,.1,.1]};
end

% Check if Line Styles are fixed across I/Os
if isscalar(LineStyles)
    LineStyleProps = {'LineStyle', LineStyles{1}};
else 
    LineStyleProps = {'LineStyle', 'none'};
end

% Check if Line Styles are fixedacross I/Os
if isscalar(Markers)
    MarkerProps = {'Marker', Markers{1}};
else 
    MarkerProps = {'Marker', 'none'};
end



if ~isscalar(LineColors) && ~isscalar(LineStyles) && isscalar(Markers) 
    if strcmpi(Markers{1},'none')
        LegendInfoVector.type = 'text';
        LegendInfo.props =  {ColorProps{:}, ...
            'VerticalAlignment', 'baseline', ...
            'String','No Mark'};
    else
        LegendInfoVector.type = 'line';
        LegendInfoVector.props =  {ColorProps{:}, ...
            MarkerProps{:}, ...
            LineStyleProps{:}, ...
            'XData', [.5,.5], 'YData',[.5,.5]};
    end
else
    LegendInfoVector.type = 'line';
    LegendInfoVector.props =  {ColorProps{:}, ...
        MarkerProps{:}, ...
        LineStyleProps{:}};
end

this.GroupLegendInfo = LegendInfoVector;
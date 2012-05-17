function makestyles(this)
%MAKESTYLES  Builds all possible style combinations.

%  Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:15 $

ColorList = this.ColorList(:,1);
if size(this.ColorList,2)==2
    ColorNameList = this.ColorList(:,2);
else
    ColorNameList = cell(size(ColorList));
end
MarkerList = this.MarkerList;
LineStyleList = this.LineStyleList;

if strcmpi(this.SortByColor,'response') 
    nstyles = length(ColorList(:,1)); 
    LegendVector = ColorNameList;
    for ct = 1:nstyles
            LegendInfoVector(ct).type = 'line';
            LegendInfoVector(ct).props =  {'Color', ColorList{ct}};
    end    
    
elseif strcmpi(this.SortByLineStyle,'response') 
    nstyles = length(LineStyleList); 
    [LegendVector, LegendInfoVector] = LocalMakeLineStyleLegend(LineStyleList);
elseif strcmpi(this.SortByMarker,'response') 
    nstyles = length(MarkerList); 
    LegendVector = MarkerList;
    LegendVector(strcmpi(LegendVector,'none')) = {''};
    for ct = 1:nstyles
        if strcmpi(MarkerList(ct),'none')
            LegendInfoVector(ct).type = 'text';
            LegendInfoVector(ct).props =  {'Color', [.1 .1 .1], ...
                       'VerticalAlignment', 'baseline', ... 
                       'String','No Mark'};
        else
            LegendInfoVector(ct).type = 'line';
            LegendInfoVector(ct).props =  {'Color', [.1 .1 .1], ...
                'Marker', MarkerList{ct}, ...
                'LineStyle', 'none', ...
                'XData', [.5,.5], 'YData',[.5,.5]};
        end
    end    
else 
    %% If the stylemanager does not sort according to response number, then 
    %% deal the same style to each response. 
    nstyles = 1; 
    LegendVector = {''};
    LegendInfoVector.type = 'text';
    LegendInfoVector.props =  {'Color', [.1 .1 .1], ...
                       'VerticalAlignment', 'baseline', ... 
                       'String',''};
    
end 

% Create style objects
for ct=nstyles:-1:1
   %% Create Style Object
   style(ct,1) = wavepack.wavestyle; 
end
 
% Fill in style objects
% RE: The Colors, LineStyles, and Markers arrays define how style attributes are 
%     distributed across the axes grid. Colors is set to
%       * 1x1 cell for uniform color
%       * 1x1xN cell for sorting responses in response array by colors
%       * Nx1 cell for sorting outputs by colors
%       * 1xN cell for sorting inputs by colors
%     (N is the number of colors). Similarly for LineStyles and Markers.
switch this.SortByColor
case 'none'
   set(style,'Colors',ColorList(1))
case 'response'
   for ct=1:nstyles
      style(ct).Colors = ColorList(ct);
   end
case 'responsearray'
   set(style,'Colors',reshape(ColorList,1,1,length(ColorList)))
case 'input'
   set(style,'Colors',reshape(ColorList,1,length(ColorList)))
case 'output'
   set(style,'Colors',reshape(ColorList,length(ColorList),1))       
end
   
switch this.SortByLineStyle
case 'none'
   set(style,'LineStyles',LineStyleList(1))
case 'response'
   for ct=1:nstyles
      style(ct).LineStyles = LineStyleList(ct);
   end
case 'responsearray'
   set(style,'LineStyles',reshape(LineStyleList,1,1,length(LineStyleList)))
case 'input'
   set(style,'LineStyles',reshape(LineStyleList,1,length(LineStyleList)))
case 'output'
   set(style,'LineStyles',reshape(LineStyleList,length(LineStyleList),1))       
end

switch this.SortByMarker
case 'none'
   set(style,'Markers',MarkerList(1))
case 'response'
   for ct=1:nstyles
      style(ct).Markers = MarkerList(ct);
   end
case 'responsearray'
   set(style,'Markers',reshape(MarkerList,1,1,length(MarkerList)))
case 'input'
   set(style,'Markers',reshape(MarkerList,1,length(MarkerList)))
case 'output'
   set(style,'Markers',reshape(MarkerList,length(MarkerList),1))       
end

% Legends
if ~isempty(LegendVector)
   for ct = 1:nstyles
      style(ct).Legend = LegendVector{ct};
      style(ct).GroupLegendInfo = LegendInfoVector(ct);
   end
end

this.Styles = style;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Local Function LocalCreateLegendString                                   --%
% Creates a matrix of legend strings                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Legends, LegendInfoVector] = LocalMakeLineStyleLegend(LineStyleList)

Legends = cell(size(LineStyleList));
Legends(strcmp(LineStyleList,'-')) = {''};
Legends(strcmp(LineStyleList,'--')) = {'dashed'};
Legends(strcmp(LineStyleList,'-.')) = {'dash-dot'};
Legends(strcmp(LineStyleList,':')) = {'dotted'};

for ct = 1:length(LineStyleList)
    LegendInfoVector(ct).type = 'line';
    LegendInfoVector(ct).props =  {'Color', [.1 .1 .10], ...
        'LineStyle', LineStyleList{ct}};
end
    
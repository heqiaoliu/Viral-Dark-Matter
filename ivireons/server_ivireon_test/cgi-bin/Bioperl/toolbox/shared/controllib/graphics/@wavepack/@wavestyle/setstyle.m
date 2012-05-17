function setstyle(this,varargin)
%SETSTYLE  User-friendly specification of  style attributes.
%
%  SETSTYLE(StyleObj,'r-x') specifies a color/linestyle/marker string.
%
%  SETSTYLE(StyleObj,'Property1',Value1,...) specifies individual style 
%  attributes.  Valid properties include Color, LineStyle, LineWidth, 
%  and Marker.

%  Author(s): P. Gahinet, Karen Gondoly
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:39 $

if nargin==2
   StyleStr = varargin{1};
   if isempty(StyleStr)
      return
   end
   [LineStyle,Color,Marker,msg] = colstyle(StyleStr);
   if ~isempty(msg)
       ctrlMsgUtils.error('Controllib:plots:PlotStyleString',StyleStr)
   end
   Values = {Color,LineStyle,[],Marker};
   
   % Finalize settings
   [Color,LineStyle,Marker,Legend] = StyleFinish(Values{[1 2 4]});
   
   % Set Style object attributes
   this.Colors = {Color};
   this.LineStyles = {LineStyle};
   this.Markers = {Marker};

   
else
   Props = {'Color','LineStyle','LineWidth','Marker'};
   Values = cell(1,4);
   if rem(length(varargin),2)
       ctrlMsgUtils.error('Controllib:general:CompletePropertyValuePairs','wavepack.wavestyle/setstyle')
   end
   for ct=1:length(varargin)/2
      prop = varargin{2*ct-1};
      idx = find(strncmpi(prop,Props,length(prop)));
      if length(idx)~=1
         ctrlMsgUtils.error('Controllib:general:AmbiguousPropertyName',prop)
      end
      Values(idx) = varargin(2*ct);
   end
   
   
   % Finalize settings
   [Color,LineStyle,Marker,Legend] = StyleFinish(Values{[1 2 4]});
   
   % Update Style object Property if the style attribute was specified as an
   % input argument or Style object Property for the attribute is empty.
   if ~isempty(Values{1}) || isempty(this.Colors)
       this.Colors = {Color};
   end
   if ~isempty(Values{2}) || isempty(this.LineStyles)
       this.LineStyles = {LineStyle};
   end
   % Linewidth has a default factory value.
   if ~isempty(Values{3}) 
       this.LineWidth = Values{3};
   end
   
   if ~isempty(Values{4}) || isempty(this.Markers)
       this.Markers = {Marker};
   end
   % Update Legend string for Right-Click Menu
   % Do not show property if its an array.
   if numel(this.Colors)>1
       Cstr = '';
   else
       Cstr = GetColorName(this.Colors{1},wavepack.colordefs('Color64'));
   end
   if numel(this.LineStyles)>1
       Lstr = '';
   else
       Lstr = this.LineStyles{1};
   end
   if numel(this.Markers)>1
       Mstr = '';
   else
       Mstr = this.Markers{1};
   end
   Legend = LocalMakeLegend(Cstr,Lstr,Mstr);
   
end

this.Legend = Legend;
this.createLegendInfo;

% Notify clients
this.send('StyleChanged')

%-------------------- Local Functions ------------------------

function [Color,LineStyle,Marker,Legend] = StyleFinish(Color,LineStyle,Marker)
% RE: All plot styles are assumed to be user specified at this point

% Load appropriate color table
rgb = (isnumeric(Color) && length(Color)==3);
if rgb,
   % Colors specified as RGB triplets
   ColorTable64 = wavepack.colordefs('Color64');
else
   ColorTable8 = wavepack.colordefs('Color8');
end

% Defaults
if isempty(Color)
   Color = 'blue';
elseif strcmp(Color,'k'),
   Color = 'black';
end

% Get RGB value and text characterization for color
if rgb,
   % Identify color name
   Cstr = GetColorName(Color,ColorTable64);
else
   % Get RGB value and full name for string color (one of eight basic colors)
   Cind = find(strncmpi(Color,ColorTable8(:,2),length(Color)));
   Color = ColorTable8{Cind(1),1};
   Cstr = ColorTable8{Cind(1),2};
end

% Resolve unspecified line styles and markers
if isempty(Marker)
   Marker = 'none';
   if isempty(LineStyle)
      LineStyle = '-';
   end
elseif isempty(LineStyle),
   LineStyle = 'none';
end

% Build legend
Legend = LocalMakeLegend(Cstr,LineStyle,Marker);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function name = GetColorName(rgbcolor,ColorTable64)

if ~isa(rgbcolor,'double') || length(rgbcolor(:))~=3
    ctrlMsgUtils.error('Controllib:plots:RGBColor')
elseif any(rgbcolor(:)<0) || any(rgbcolor(:)>1)
    ctrlMsgUtils.error('Controllib:plots:RGBColor')
end

% Preprocessing
if min(rgbcolor)>0.9,
   rgbcolor = [1 1 1];
elseif max(rgbcolor)<0.5
   rgbcolor = [0 0 0];
elseif max(abs(rgbcolor-mean(rgbcolor)))<0.1
   rgbcolor = mean(rgbcolor) * [1 1 1];
end

AllRGBs = cat(1,ColorTable64{:,1});
gaps = sum(abs(AllRGBs - rgbcolor(ones(length(ColorTable64),1),:)).^2,2);
[garb,imatch] = min(gaps);

name = ColorTable64{imatch,2};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LegendStr = LocalMakeLegend(Cstr,LL,MM)
%LEGDSTR  Creates color/linestyle/marker legend for Response Object menus

% Determine line style name
if get(0,'ScreenDepth')==1 % Monochrome screen
   Lind = find(strcmpi(LL,{'--';'-.';':';'-'}));
else
   % Solid = default (don't mention)
   Lind = find(strcmpi(LL,{'--';'-.';':'}));
end

if length(Lind)==1
   AllLines = {'dashed';'dash-dot';'dotted';'solid'};
   Lstr = AllLines{Lind};
else
   % Assume 'none'
   Lstr = '';
end      

% Set marker name
Mstr = MM;
if strcmp(Mstr,'none'), % Don't bother showing empty markerstyles
   Mstr = '';
end

% Construct legend string
LegendStr = Cstr;
if ~isempty(Lstr)
   LegendStr = sprintf('%s,%s',LegendStr,Lstr);
end
if ~isempty(Mstr),
   LegendStr = sprintf('%s,%s',LegendStr,Mstr);
end




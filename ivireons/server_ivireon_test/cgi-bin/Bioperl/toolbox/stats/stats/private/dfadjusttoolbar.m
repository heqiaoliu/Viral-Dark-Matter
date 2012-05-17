function dfadjusttoolbar(dffig)
%DFADJUSTTOOLBAR Adjust contents of distribution fitting plot toolbar

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:31 $
%   Copyright 2003-2008 The MathWorks, Inc.

h0 = findall(dffig,'Type','uitoolbar');
h1 = findall(h0,'Parent',h0);
czoom = [];
for j=length(h1):-1:1
   mlabel = get(h1(j),xlate('TooltipString'));
   if ~isempty(findstr(mlabel,'Zoom')) || ~isempty(findstr(mlabel,'Pan'))
      czoom(end+1) = h1(j);
   elseif isempty(findstr(mlabel,'Print'))
      delete(h1(j));
      h1(j) = [];
   else
     c1 = h1(j);
   end
end

% Add more icons especially for distribution fitting
state = dfgetset('showlegend');
if isempty(state), state = 'on'; end
c2 = uitoolfactory(h0,'Annotation.InsertLegend');
set(c2, 'State',state,...
        'TooltipString', 'Legend On/Off',...
        'Separator','on',...
        'ClickedCallback','dfittool(''togglelegend'')',...
        'Tag','showlegend');
    
if exist('dficons.mat','file')==2
   icons = load('dficons.mat','icons');
   state = dfgetset('showgrid');
   if isempty(state), state = 'off'; end
   c3 = uitoggletool(h0, 'CData',icons.icons.grid,...
                    'State',state,...
                    'TooltipString', ('Grid On/Off'),...
                    'Separator','off',...
                    'ClickedCallback','dfittool(''togglegrid'')',...
                    'Tag','showgrid');
   c4 = uipushtool(h0, 'CData',icons.icons.resetview,...
                    'TooltipString', ('Restore Default Axes Limits'),...
                    'Separator','off',...
                    'ClickedCallback','dfittool(''defaultaxes'')', ...
                    'Tag','defaultaxes');
   cnew = [c1 czoom c2 c3 c4]';
   
   set(h0,'Children',cnew(end:-1:1));
end

function addLegend(this,ax,is2D)
% Add legend to axes "ax" for plot "plottype", by making a list of all lines
% and reading their tags.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:22:03 $

if is2D
    allLines = findobj(ax,'type','line');
else
    allLines = findobj(ax,'type','surface');
end

for k = 1:length(allLines)
    hasbehavior(allLines(k),'legend',false)
end
    
if is2D
    lines = findobj(allLines,'type','line','visible','on'); %
else
    lines = findobj(allLines,'type','surface','visible','on'); %
end

if isempty(lines)
    legend(ax,'off')
    return
end

% todo: stacking of lines is reversed; is this a reliable behavior?
lines = lines(end:-1:1); 
tags = get(lines,{'Tag'});

for k = 1:length(lines)
    hasbehavior(lines(k),'legend',true)
end


nlo = get(lines,{'userdata'});
L = length(nlo);
legnames = cell(L,1);
for i = 1:L
    legnames{i} = sprintf('%s:%s',tags{i},nlo{i});
end
legend(ax,legnames,'location','NorthEast');

if ~this.showLegend
    legend(ax,'off')
end

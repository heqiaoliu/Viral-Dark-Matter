function addLegend(this,ax)
% Add legend to axes "ax" for plot "plottype", by making a list of all lines
% and reading their tags

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:10 $

allLines = findobj(ax,'type','line');
for k = 1:length(allLines)
    hasbehavior(allLines(k),'legend',false)
end
    
lines = findobj(allLines,'type','line','visible','on'); %

if isempty(lines)
    return
end

% todo: stacking of lines is reversed; is this a reliable behavior?
lines = lines(end:-1:1); 
tags = get(lines,{'Tag'});

for k = 1:length(lines)
    hasbehavior(lines(k),'legend',true)
end

% switch lower(plottype)    
%     case 'pzmap'
%         markers = get(lines,'Marker');
%         legnames = {};
%         for k = 1:length(lines)
%             if strcmp(markers{k},'x')
%                 legnames{end+1} = ['poles:',tags{k}];
%             elseif strcmp(markers{k},'o')
%                 legnames{end+1} = ['zeros:',tags{k}];
%             end
%         end
%     otherwise
%         legnames = tags;
% end

axtype = get(ax,'userdata');
if strncmp(axtype,'nonlinear',9)
    nlo = get(lines,{'userdata'});
    L = length(nlo);
    legnames = cell(L,1);
    for i = 1:L
        legnames{i} = sprintf('%s:%s',tags{i},class(nlo{i}));
    end
else
    legnames = tags; 
end
legend(ax,legnames);

if ~this.showLegend
    legend(ax,'hide')
end
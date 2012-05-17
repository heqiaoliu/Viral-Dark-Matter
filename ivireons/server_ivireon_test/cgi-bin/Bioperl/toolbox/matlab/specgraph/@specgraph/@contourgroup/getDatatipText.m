function str = getDatatipText(this,dataCursor)
%GETDATATIPTEXT Get contour datatip text
  
%   Copyright 1984-2005 The MathWorks, Inc. 

x = get(this,'XData');
y = get(this,'YData');
z = get(this,'ZData');

% DataIndex was computed in updateDataCursor
ind = dataCursor.DataIndex;

%Deal with two possible cases: XData and YData are vectors, or XData and
%YData are rectangular matrices
if isvector(x) && isvector(y)
	xstr = num2str(x(ind(1)));
	ystr = num2str(y(ind(2)));
	%In this case, the indices into ZData are swapped
	zstr = num2str(z(ind(2),ind(1)));
else
	xstr = num2str(x(ind(1),ind(2)));
	ystr = num2str(y(ind(1),ind(2)));
	zstr = num2str(z(ind(1),ind(2)));
end

str = {['X= ' xstr], ...
       ['Y= ' ystr], ...
       ['Level= ' zstr]};

if ~isempty(this.DisplayName)
  str = {this.DisplayName,str{:}};
end
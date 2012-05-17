function out1 = getmenus(h)

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:25 $

nummenus = length(h.menulabels);
if nummenus > 0
	out1 = javaArray('java.lang.String',nummenus);
	for k=1:nummenus
            out1(k) = java.lang.String(h.menulabels{k});
	end
else % This function must return a valid string
    out1 = javaArray('java.lang.String',1);
    out1(1) = java.lang.String('');
end

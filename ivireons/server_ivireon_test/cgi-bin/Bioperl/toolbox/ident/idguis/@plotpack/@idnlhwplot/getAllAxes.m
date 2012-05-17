function ax = getAllAxes(this)
% get handles of all plot axes

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:24 $

axall = findall(this.MainPanels,'type','axes');
ax = zeros(0,1);
for k = 1:length(axall)
    axtype = get(axall(k),'user');
    if any(strcmpi(axtype,{'step','impulse','bode','pzmap'})) ||...
            strncmp(axtype,'nonlinear',9)
        ax(end+1,1) = axall(k);
    end
end

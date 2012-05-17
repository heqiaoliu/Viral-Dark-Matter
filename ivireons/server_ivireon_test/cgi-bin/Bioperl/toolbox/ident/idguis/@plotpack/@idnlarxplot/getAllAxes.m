function ax = getAllAxes(this)
% get handles of all plot axes

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:49 $

ynames = this.OutputNames;
ax = zeros(0,1);
for k = 1:length(ynames)
    axk = findobj(this.MainPanels,'type','axes','tag',ynames{k});
    if ~isempty(axk)
        ax(end+1,1) = axk;
    end
end

function axout = utgetaxes(fig,varargin)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

% UTGETAXES

% Utility used by preprocessing to access the axes children matching
% various criteria
a = get(fig,'Children');
ax = findobj(a,'flat','Type','axes');
ap = findobj(a,'flat','Type','uipanel');
for k=1:length(ap)
    ax = [ax; findobj(get(ap(k),'children'),'Type', 'axes')];
end


if nargin >1
    axout = [];
    k = 1;
    for j=1:length(ax)
       if strcmp(get(ax(j),'Tag'),varargin{1})
          axout(k) = ax(j);
          k = k+1;
       end
    end
else
    axout = ax;
end

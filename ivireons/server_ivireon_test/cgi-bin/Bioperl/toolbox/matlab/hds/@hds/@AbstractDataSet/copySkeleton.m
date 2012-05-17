function D = copySkeleton(this)
%COPYSKELETON  Copies data set skeleton (data is not copied)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:17 $
   
% Copy skeleton, excluding parent
D = feval(class(this));
Vars = getvars(this);
for ct=1:length(Vars)
   D.addvar(Vars(ct));
end
Links = getlinks(this);
for ct=1:length(Links)
   D.addlink(Links(ct));
end

% Copy grid
D.setgrid(this.Grid_.Variable);

% Copy containers
% UDDREVISIT
% for ct=1:length(this.Data_)
%    D.Data_(ct) = copy(this.Data_(ct),DataCopy);
% end
Data = D.Data_;
for ct=1:length(this.Data_)
   Data(ct,1) = copy(this.Data_(ct),false);
end
D.Data_ = Data;

% UDDREVISIT
% for ct=1:length(this.Children_)
%    D.Children_(ct) = copy(this.Children_(ct),DataCopy);
% end
Links = D.Children_;
for ct=1:length(this.Children_)
   Links(ct) = copy(this.Children_(ct),false);
end
D.Children_ = Links;


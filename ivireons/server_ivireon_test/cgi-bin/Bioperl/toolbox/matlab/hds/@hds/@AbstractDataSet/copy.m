function D = copy(this,varargin)
%COPY  Copy method for data sets.
%
%   D2 = COPY(D) creates a copy of the data set this. All data is copied
%   over, but no deep copy is performed on linked data sets.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 18:13:16 $

% RE: Limitations
%     1) No deep copy of linked (dependent) data sets 
%     2) Data stored in MAT file or other external source 
%        does not get copied

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

% Copy grid info
D.Grid_ = this.Grid_;
D.Cache_.GridDim = this.Cache_.GridDim;

% Copy containers
% UDDREVISIT
% for ct=1:length(this.Data_)
%    D.Data_(ct) = copy(this.Data_(ct),true);
% end
Data = D.Data_;
for ct=1:length(this.Data_)
   Data(ct,1) = copy(this.Data_(ct),true);
end
D.Data_ = Data;

% UDDREVISIT
% for ct=1:length(this.Children_)
%    D.Children_(ct) = copy(this.Children_(ct),true);
% end
Links = D.Children_;
for ct=1:length(this.Children_)
   Links(ct) = copy(this.Children_(ct),true);
end
D.Children_ = Links;


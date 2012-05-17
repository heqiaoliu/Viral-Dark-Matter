function setScalar(this,DSScalar,GridSize)
%SETSCALAR  Scalar assignment into link array.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:04 $

% Clear cached variable data (entire data link is being redefined)
LinkArray.LinkedVariables = [];
LinkArray.SharedVariables = [];

% Check specified data set
this.checkLinks(DSScalar);

% Populate link array
Links = cell(GridSize);
DS = DSScalar{1};
for ct=1:prod(GridSize)
   % Clone data set
   if ct==1
      Links{ct} = DS;
   else
      % RE: Also copies data
      Links{ct} = copy(DS);
   end
end
this.Links = Links;

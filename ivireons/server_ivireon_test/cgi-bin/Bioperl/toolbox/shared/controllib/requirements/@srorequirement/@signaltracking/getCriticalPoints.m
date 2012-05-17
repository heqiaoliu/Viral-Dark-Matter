function Th = getCriticalPoints(this)
% GETCRITICALPOINTS method to compute simulation horizon and time points 
% needed for proper requirement evaluation.
 
% Author(s): A. Stothert 25-Feb-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:58 $

X = this.Data.getData('xdata');
Th = [min(X(:)); max(X(:))];

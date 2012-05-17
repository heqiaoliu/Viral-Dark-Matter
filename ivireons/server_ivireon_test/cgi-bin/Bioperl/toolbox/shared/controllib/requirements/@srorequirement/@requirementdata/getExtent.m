function [X,Y] = getExtent(this) 
% GETEXTENT  Method to return bounded extent of a constraint, if constraint
% has openend(s) only the finite extent is returned
%
% Output:
%    X     - 2x1 array of doubles with [xMin; xMax]
%    Y     - 2x1 array of doubles with [yMin; yMax]

% Author(s): A. Stothert 06-May-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:32 $

X = [min(this.xCoords(:)); max(this.xCoords(:))];
Y = [min(this.yCoords(:)); max(this.yCoords(:))];

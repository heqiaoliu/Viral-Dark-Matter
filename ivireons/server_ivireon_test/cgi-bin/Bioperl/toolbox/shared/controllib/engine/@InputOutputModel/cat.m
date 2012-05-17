function M = cat(dim,varargin)
%CAT  Concatenation of input/output models.
%
%   M = CAT(DIM,M1,M2,...) concatenates the input/output models M1,M2,...
%   along the dimension DIM.  The values DIM=1,2 correspond to the output 
%   (row) and input (column) dimensions, and the values DIM=3,4,... 
%   correspond to the model array dimensions 1,2,...
%
%   For example,
%     * CAT(1,M1,M2) is equivalent to [M1 ; M2]
%     * CAT(2,M1,M2) is equivalent to [M1 , M2]
%     * CAT(4,M1,M2) is equivalent to STACK(2,M1,M2).
%
%   See also HORZCAT, VERTCAT, STACK, APPEND, DYNAMICSYSTEM, STATICMODEL.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:54 $
switch dim
case 1
   M = vertcat(varargin{:});
case 2
   M = horzcat(varargin{:});
otherwise
   M = stack(dim-2,varargin{:});
end


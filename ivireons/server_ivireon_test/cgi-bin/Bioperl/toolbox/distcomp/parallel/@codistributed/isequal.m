function flag = isequal(varargin)
%ISEQUAL True if codistributed arrays are numerically equal
%   TF = ISEQUAL(A,B)
%   TF = ISEQUAL(A,B,C,...)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.nan(N);
%       f = isequal(D,D)
%       t = isequalwithequalnans(D,D)
%   end
%   
%   returns f = false and t = true.
%   
%   See also ISEQUAL, CODISTRIBUTED, CODISTRIBUTED/NAN.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:58:42 $

flag = isequaltemplate(@isequal,varargin{:});

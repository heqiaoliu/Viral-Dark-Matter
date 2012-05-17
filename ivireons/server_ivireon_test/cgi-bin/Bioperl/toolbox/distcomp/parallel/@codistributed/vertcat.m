function C = vertcat(varargin)
%VERTCAT Vertical concatenation for codistributed array
%   C = VERTCAT(A,B,...) implements [A; B; ...] for codistributed arrays.
%   If any of A, B, ... is distributed by columns, so is C.
%   If all of A, B, ... are distributed by rows, so is C.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       D2 = [D; D] % a 2000-by-1000 codistributed matrix
%   end
%   
%   See also VERTCAT, CODISTRIBUTED, CODISTRIBUTED/CAT.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 02:00:09 $

C = cat(1,varargin{:});

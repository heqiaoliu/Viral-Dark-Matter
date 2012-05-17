function C = horzcat(varargin)
%HORZCAT Horizontal concatenation of codistributed arrays
%   C = HORZCAT(A,B,...) implements [A B ...] for codistributed arrays.
%   If any of A, B, ... is distributed by rows, so is C.
%   If all of A, B, ... are distributed by columns, so is C.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       D2 = [D D] % a 1000-by-2000 codistributed matrix
%   end
%   
%   See also HORZCAT, CODISTRIBUTED, CODISTRIBUTED/CAT.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:58:34 $

C = cat(2,varargin{:});

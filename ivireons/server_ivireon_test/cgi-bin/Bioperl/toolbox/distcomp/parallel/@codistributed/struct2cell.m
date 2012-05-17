function c = struct2cell(s)
%STRUCT2CELL Convert structure codistributed array to cell codistributed array
%   C = STRUCT2CELL(S)
%   
%   If the original struct array is distributed along dimension DIM, the
%   resulting cell array will be distributed along dimension DIM+1.
%   
%   Example:
%   spmd
%       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
%       names    = {'a','b','c','d','e','f','g','h','i','j'};
%       s = struct('matrix', matrices, 'name', names);
%       S = codistributed(s)
%       C = struct2cell(S)
%       classS = classUnderlying(S)
%       classC = classUnderlying(C)
%   end
%   
%   converts the 1-by-10 codistributed array of structs S to the
%   2-by-1-by-10 codistributed cell array C.
%   classS is 'struct' while classC is 'cell'.
%   
%   See also STRUCT2CELL, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:51:22 $

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('struct2cell', s); %#ok<DCUNK> private static

sDist = getCodistributor(s);
d = sDist.Dimension;
c = struct2cell(getLocalPart(s));
c = codistributed.build(c, codistributor('1d', d+1), 'obsolete:matchLocalParts');

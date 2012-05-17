function names = fieldnames(obj, optArg)
%FIELDNAMES Get structure field names of codistributed array
%   NAMES = FIELDNAMES(S)
%   
%   Example:
%   spmd
%       matrices = { 1,  2,  3,  4,  5,  6,  7,  8,  9,  10};
%       names    = {'a','b','c','d','e','f','g','h','i','j'};
%       s = struct('matrix', matrices, 'name', names);
%       S = codistributed(s)
%       f = fieldnames(S)
%   end
%   
%   returns the field names f = {'matrix','name'} of the 1-by-10
%   codistributed array of structs S.
%   
%   See also FIELDNAMES, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:36 $

if nargin < 2
    optArg = [];
else
    optArg = distributedutil.CodistParser.gatherIfCodistributed(optArg);
end

if ~isa(obj, 'codistributed')
    names = fieldnames(obj, optArg);
    return;
end

objDist = getCodistributor(obj);
localObj = getLocalPart(obj);

names = objDist.hFieldnamesImpl(localObj, optArg);



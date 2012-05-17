function out = typecast(in, datatype)
%TYPECAST Convert datatypes of codistributed array without changing underlying data
%   Y = TYPECAST(X, DATATYPE)
%   
%   Example:
%   spmd
%       N = 1000;
%       Di = -1*codistributed.ones(1,N,'int8');
%       Du = typecast(Di,'uint8')
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   end
%   
%   type casts the 1-by-N codistributed uint8 row vector Du to the
%   codistributed int8 array Di.
%   Di has all values -1 while Du has all values 255.
%   classDi is 'int8' while classDu is 'uint8'.
%   
%   See also TYPECAST, CODISTRIBUTED, CODISTRIBUTED/ONES, 
%   CODISTRIBUTED/CLASSUNDERLYING.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:51:30 $

error(nargchk(2, 2, nargin, 'struct'))

datatype = distributedutil.CodistParser.gatherIfCodistributed(datatype);
if ~isa(in, 'codistributed')
    out = typecast(in,datatype);
    return;
end

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('typecast', in); %#ok<DCUNK> private static

% Error out right away if the first argument is not a vector.
% I can't rely on the native typecast to handle this because some or all of
% the local arrays may be vectors
if ~isvector(in) && ~isempty(in)
    error('distcomp:codistributed:typecast:firstArgMustBeVector', ...
        'The first input argument must be a vector.');
end

inDist = getCodistributor(in);
d = inDist.Dimension;
vector_distributed_to_singleton = size(in, d) == 1 && length(in) > 1;
try
    final_class_size = find_size(datatype);
    orig_class_size = find_size(class(getLocalPart(in)));
catch err
    error('distcomp:codistributed:typecast:unsupportedClass', ...
        'Unsupported class.');
end

% if there is a mismatch in sizes and the end size is bigger than the beginning
% size, we need to check if the size of the array is valid, and if it is, and
% the size of the codistributed arrays don't all create whole values, we need to
% redistribute them so they only create an integer number of values of the new
% class.
if orig_class_size < final_class_size
    part = inDist.Partition;
    total_size = length(in);
    min_block_size = final_class_size ./ gcd(orig_class_size, final_class_size);
    if rem(total_size, min_block_size) ~= 0
        error('distcomp:codistributed:typecast:notEnoughInputElements', ...
            'Too few input values to make output type.');
    elseif any(rem(part, min_block_size)) ...
      && ~vector_distributed_to_singleton
        for index = 1:numlabs - 1
            part(index) = part(index) - rem(part(index), min_block_size);
            total_size = total_size - part(index);
        end
        part(numlabs) = total_size;
        in = redistribute(in,codistributor('1d',d,part));
    end
end
% Now that we insured that each lab will create an integer number of new
% values, now perform the typecast.
result = typecast(getLocalPart(in), datatype);

% Handle the case where the vector is not distributed on the non singleton
% dimension
if isempty(result) && vector_distributed_to_singleton
  new_size = size(result);
  vec_idx = find(new_size > 0, 1);
  new_size(vec_idx) = (new_size(vec_idx) .* orig_class_size) ./ final_class_size;
  result = reshape(result, new_size);
end
out = codistributed.build(result, codistributor('1d', d), 'obsolete:matchLocalParts');
end


% A helper function that uses the typecast function to provide the size
% of a class.  This should error out on a non built in class.
function bytes = find_size(datatype)

size_one_array = feval(datatype, 0);
converted_array = typecast(size_one_array, 'int8');
bytes = length(converted_array);
end

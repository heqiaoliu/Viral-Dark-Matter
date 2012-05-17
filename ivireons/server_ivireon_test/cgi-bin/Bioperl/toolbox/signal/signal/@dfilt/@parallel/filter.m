function y = filter(Hd,x,dim)
%FILTER Discrete-time filter.
%   Y= FILTER(Hd,X,DIM) filters data X over dimension DIM with and returns
%   output Y. 
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.11 $  $Date: 2006/06/27 23:34:49 $

% parallel/filter is not supported for for fixed-pt filters
if ~isparallelfilterable(Hd)
    msg = 'Filtering is not supported for fixed-point filters connected in parallel.';
    msgid = generatemsgid('ParallelFixedFilter');
    error(msgid,msg);
end

% Check if all stages have the same overall rate change factor
checkvalidparallel(Hd);

if nargin<3, dim=[]; end

if isempty(x), 
  y = x;
  return; 
end

% Because this filter method used to allow for specifying the states as the
% third input, we check that the DIM input is not a vector/matrix.
if any(size(dim)>1),
    msg = 'Dimension argument must be a positive integer scalar in the range 1 to 2^31.';
    msgid = generatemsgid('DimMustBeInt');
    error(msgid,msg);
end

% Get current value of reset states
resetval = Hd.PersistentMemory;

y = 0;

flagdiff = false;
for k=1:length(Hd.Stage)
    if Hd.Stage(k).PersistentMemory~=resetval,
        Hd.Stage(k).PersistentMemory = resetval;
        flagdiff = true;
    end
    yk = filter(Hd.Stage(k),x,dim);
    y = y + yk;
end

if flagdiff,
     warning(generatemsgid('flagInconsistency'), ...
        ['PersistentMemory flag turned ', mat2str(resetval), ' for each stage.']);
end

% Set reset states back to what it was
Hd.PersistentMemory = resetval;
Hd.NumSamplesProcessed = Hd.Stage(1).NumSamplesProcessed;

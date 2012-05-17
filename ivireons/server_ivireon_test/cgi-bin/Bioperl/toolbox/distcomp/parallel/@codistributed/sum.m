function S = sum(A, varargin)
%SUM Sum of elements of codistributed array
%   SUM(X)
%   SUM(X,'double')
%   SUM(X,'native')
%   SUM(X,DIM)
%   SUM(X,DIM,'double')
%   SUM(X,DIM,'native')
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N)
%       s = sum(D)
%   end
%   
%   returns s = (1+1000)*1000/2 = 500500.
%   
%   The order of the additions within the SUM operation is not defined, so
%   the SUM operation on codistributed array might not return exactly the same 
%   answer as the SUM operation on the corresponding MATLAB numeric array.
%   In particular, the differences might be significant when X is a signed
%   integer type and its sum is accumulated natively.
%   
%   See also SUM, CODISTRIBUTED, CODISTRIBUTED/ZEROS.
%   
%   


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/14 16:51:25 $

error(nargchk(1, 3, nargin, 'struct'));

argList = distributedutil.CodistParser.gatherElements(varargin);
if ~isa(A, 'codistributed')
    % Dimension or accumType are codistributed, but not the array itself.
    S = sum(A, argList{:});
    return;
end

% Unlike the other reduction functions (any, all, prod), sum takes a 3rd
% optional argument, the accumulative type.  We peel that off and hide from our
% generic reduction processing.
if length(argList) == 2 || (length(argList) == 1 && ischar(argList{1}))
    accumType = argList{end};
    argList(end) = [];
else
    % Use default accummulative type.
    if strcmp(classUnderlying(A),'single')
        accumType = 'native';
    else
        accumType = 'double';
    end
end
% Forward accumType to sum, then reduce.
fcn = @(varargin) sum(varargin{:}, accumType);
S = codistributed.pReductionOpAlongDim(fcn, A, argList{:}); %#ok<DCUNK> Calling private static method.

end


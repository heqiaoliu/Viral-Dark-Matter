function varargout = lu( varargin )
%LU LU factorization for GPUArray
%   [L,U,P] = LU(D, 'vector')
%   
%   D must be a full GPUArray matrix of floating point numbers (single or double).
%   
%   The following syntaxes are not supported for full GPUArray D:
%   [...] = LU(D)
%   [...] = LU(D,'matrix')
%   X = LU(D,'vector')
%   [L,U] = LU(D,'vector')
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       [L,U,piv] = lu(D,'vector');
%   
%   See also LU, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:28:10 $

if nargin~=2 
     error('parallel:gpu:lu:invalidInputs',...
         'Invalid number of inputs.  The only supported syntax is [L, U, p] = lu(A, ''vector'').');  
end 

if nargout~=3 
     error('parallel:gpu:lu:invalidOutputs',...
         'Invalid number of outputs.  The only supported syntax is [L, U, p] = lu(A, ''vector'').');  
end

obj = varargin{1};

% Handle non-data arg being GPUArray
[objIsGpu, args{1:nargin-1}] = gatherIfNecessary( obj, varargin{2:end} );
if ~objIsGpu
    [varargout{1:nargout}] = lu(obj, args{:});
    return
end

if ~strcmpi(args{:}, 'vector')
   error('parallel:gpu:lu:supported',...
         'The only supported syntax is [L, U, p] = lu(A, ''vector'').');
end

if ~hIsFloat(obj) || ndims(obj) > 2
    error('parallel:gpu:lu:invalidInput', ...
          'LU executed on a GPU is supported only for full floating point arrays.');
end

try
    [varargout{1:nargout}]=hLu( obj, args{:} );
catch E
    throw(E);
end

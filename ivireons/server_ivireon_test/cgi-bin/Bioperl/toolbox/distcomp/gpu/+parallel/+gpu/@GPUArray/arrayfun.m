function varargout = arrayfun(func, varargin)
%ARRAYFUN Apply a function to each element of an array on the GPU.
%   
%       This method of GPUArray is very similar in behaviour to the MATLAB
%       function ARRAYFUN, except that the actual evaluation of the function
%       happens on the GPU, not on the CPU. Thus any required data not
%       already on the GPU is move to GPU memory, the MATLAB function
%       referenced by FUN is compiled for the GPU, and then executed on the
%       GPU. All the output arguments are returned as GPUArrays whose data
%       can be retrieved with the GATHER method.
%   
%       A = ARRAYFUN(FUN, B) applies the function specified by FUN to each
%       element of the GPUArray B, and returns the results in GPUArray A.  A
%       is the same size as B, and the (I,J,...)th element of A is equal to
%       FUN(B(I,J,...)). FUN is a function handle to a function that takes
%       one input argument and returns a scalar value. FUN must return values
%       of the same class each time it is called.  The inputs must be arrays
%       of the following types:  numeric, logical, or GPUArray.  The order in
%       which ARRAYFUN computes elements of A is not specified and should not
%       be relied on.
%   
%       FUN must be a handle to a function that is written in the MATLAB
%       language (i.e., not a built-in function or a mex function); it must
%       not be a nested, anonymous, or sub-function; and the MATLAB file that
%       defines the function must contain exactly one function definition.
%   
%       The subset of the MATLAB language that is currently supported for 
%       compilation on the GPU can be found <a href="matlab:helpview(fullfile(docroot,'toolbox','distcomp','distcomp.map'), 'GPU_SUPPORTED_MATLAB')">here</a>
%   
%       A = ARRAYFUN(FUN, B, C,  ...) evaluates FUN using elements of arrays
%       B, C,  ... as input arguments.  The (I,J,...)th element of the
%       GPUArray A is equal to FUN(B(I,J,...), C(I,J,...), ...).  B, C, ...
%       must all have the same size or be scalar. Any of the inputs that are
%       scalar will be scalar expanded before input to the function FUN.
%   
%       One or more of the inputs B, C, ... must be a GPUArray, with the
%       others being held in CPU memory. Each array that is held in CPU
%       memory will be converted to a GPUArray before calling the function on
%       the GPU. If an array is to be used in several different ARRAYFUN
%       calls it is more efficient to convert that array to a GPUArray before
%       calling the series of ARRAYFUN methods.
%   
%       [A, B, ...] = ARRAYFUN(FUN, C, ...), where FUN is a function handle
%       to a function that returns multiple outputs, returns GPUArrays A, B,
%       ..., each corresponding to one of the output arguments of FUN.
%       ARRAYFUN calls FUN each time with as many outputs as there are in the
%       call to ARRAYFUN.  FUN can return output arguments having different
%       classes, but the class of each output must be the same each time FUN
%       is called. This means that all elements of A must be the same class;
%       B can be a different class from A, but all elements of B must be of
%       the same class.
%   
%   
%       Examples
%         If you define a MATLAB function as follows:
%           function [o1, o2] = aGpuFunction(a, b, c)
%           o1 = a + b;
%           o2 = o1 .* c + 2;
%         
%         Then this can be called on the GPU:
%         
%         s1 = gpuArray(rand(400));
%         s2 = gpuArray(rand(400));
%         s3 = gpuArray(rand(400));
%         [o1, o2] = arrayfun(@aGpuFunction, s1, s2, s3)
%         o1 =
%         parallel.gpu.GPUArray:
%         ---------------------
%                        Size: [400 400]
%             ClassUnderlying: 'double'
%                  Complexity: 'real'
%         o2 =
%         parallel.gpu.GPUArray:
%         ---------------------
%                        Size: [400 400]
%             ClassUnderlying: 'double'
%                  Complexity: 'real'      
%   
%   
%          See also  gpuArray, function_handle, gather, PARALLEL.GPU.GPUARRAY
%   
%   


%   Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2010/06/21 17:56:46 $

if nargin < 1 || ~isa(func, 'function_handle')
    error('parallel:gpu:InvalidInput', 'The first input to arrayfun must be a function handle.');
end

if numel(varargin) < 1
    error('parallel:gpu:InvalidInput', 'There must be at least one numeric input to arrayfun.');
end

% We always need to check our input arguments are all arrays of the same
% size or are scalars - we will do scalar expansion later
try
    outputSize = iGetOutputSize(varargin);
catch err
    throw(err);
end

% Get a CUDA kernel for this function handle and set of input arguments.
% NOTE This should be very fast if we already have the relevant kernel, but
% could be slower if we are compiling the code for the first time. This
% could throw all sorts of different errors if the code is incorrect
try
    kernelFunc = iGetKernelFromFunctionHandle(func);
catch err
    throw(err);
end

try
    varargout = cell(max(nargout, 1),1);
    [varargout{:}] =  kernelFunc(outputSize, varargin{:});
catch err
    theErr = MException(err.identifier, 'Could not run %s on the GPU.\n\nCaused by:\n\n%s', func2str(func), err.message );
    throw(theErr)
end 

end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function kernelCall = iGetKernelFromFunctionHandle(func)
% Given a function handle and an input signature this function looks in the
% global cache for an available kernel. It also checks to see if that
% MATLAB file has been reloaded by core MATLAB (i.e. that the base MATLAB
% code has changed)

persistent funcMap;
if isempty(funcMap)
    funcMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
end

info = functions(func);
filename = info.file;

% Look in the kernelMap to see if we know about this file
funcInfoValid = funcMap.isKey(filename);

if funcInfoValid
    % Get the timestamp
    timestamp = pct_getFunctionTimestamp(func);
    % Get timestamp for function handle 
    funcInfo = funcMap(filename);
    % Timestamps are the same so we can use the kernel map
    funcInfoValid = isequal(funcInfo.timestamp, timestamp);
    if funcInfoValid
        kernelCall = funcInfo.kernelCall;
    end
else
    % Check that the function handle is OK
    iCheckIsValidFunctionHandle(func);
    % Now get the last timestamp for that function handle
    timestamp = pct_getFunctionTimestamp(func);
    % Don't even know about this function - make a new function info struct
    funcInfo = struct('timestamp', [], ...
        'kernelCall', []);
end
% If either the kernelMap of the funcInfo do not exist or are out of date
% then we will rebuild the kernel map from scratch
if ~funcInfoValid
    kernelCall = parallel.internal.gpu.gpuplan(filename);
    funcInfo.kernelCall = kernelCall;
    funcInfo.timestamp = timestamp;
    funcMap(filename) = funcInfo;
end

end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iCheckIsValidFunctionHandle(func)
info = functions(func);
% The function handle cannot be scoped, anonymous or nested
if ~strcmp( info.type, 'simple' )
    error('parallel:gpu:InvalidFunctionHandle', ...
        'Only MATLAB files containing a single function are supported on the GPU.');
end
% Built-ins can also be simple, so check that the file also exists. This
% proves that the function handle is backed by a valid file that we can
% parse.
if ~exist( info.file, 'file' )
    % Now we need to distinguish between a built-in and a missing file
    if isempty(which(info.function))
        error('parallel:gpu:InvalidFunctionHandle', ...
            'Undefined function ''%s''.', info.function);
    else
        error('parallel:gpu:InvalidFunctionHandle', ...
            'Only MATLAB files containing a single function are supported on the GPU.');
    end
end
end


% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function theSize = iGetOutputSize(args)
% Holder for the allowed array size of the inputs
theSize = [];
theSizeIndex = 0;
theScalarArgs = false(numel(args), 1);
SIZE_SET = false;
% Loop over all inputs
for i = 1:numel(args)
    anArg = args{i};
    aSize = size(anArg);
    argIsScalar = numel(anArg) == 1;
    % If this isn't a scalar
    if ~argIsScalar 
        % Is the array size set yet? Set this ONLY once
        if ~SIZE_SET
            theSize = aSize;
            theSizeIndex = i;
            SIZE_SET = true;
        else
            if ~isequal( aSize, theSize )
                % Error indicating that sizes are NOT matched correctly
                theSizeStr = sprintf('%dx', theSize);
                aSizeStr   = sprintf('%dx', aSize);
                error('parallel:gpu:InvalidInput', ...
                    ['All of the input arguments must be of the same size and shape or scalar. ' ...
                    'Input argument %d has size %s and input %d has size %s.'], ...
                    theSizeIndex, theSizeStr(1:end-1), i, aSizeStr(1:end-1) );
            end
        end
    end
    theScalarArgs(i) = argIsScalar;
end
if all(theScalarArgs)
    theSize = [1 1];
end
end


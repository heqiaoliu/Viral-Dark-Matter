function [ kernelLocal, kernelTable ] = pPtxFactoryInterface(tree,inputSig,kernelLocal,kernelTable,varargin)
% Helper function for kernel management of operator overloads.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/10 14:27:31 $

% Search for cached kernel.
[m,~] = size(kernelLocal);

for k = 1:m
    if all( inputSig == kernelLocal(k,:) ) ...
            && kernelTable.(inputSig).kernel.Valid
        return;
    end
end

% Make new kernel or load cached kernel.
ruleset = 'vector';
printlinenumber = false;
[codelet,prototype,~,types,complexities] = ...
    parallel.internal.gpu.ptxFactoryInterface(ruleset,printlinenumber,tree,varargin{:});

gpuLocalKernel = parallel.gpu.CUDAKernel(codelet,prototype);
kernelTable.(inputSig).kernel = gpuLocalKernel;
kernelTable.(inputSig).types = types;
kernelTable.(inputSig).complexities = complexities;

kernelLocal = [ kernelLocal; inputSig ];

   
end


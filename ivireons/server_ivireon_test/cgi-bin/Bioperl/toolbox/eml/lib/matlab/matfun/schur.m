function [V,T] = schur(A,opt)
%Embedded MATLAB Library Function

%   Limitations:

%   1. The SCHUR decomposition is not unique, and outputs may not match
%      MATLAB.  However, the decomposition should be of the same quality as
%      in MATLAB, i.e. A ~= V*T*V'.

%   Copyright 2010 The MathWorks, Inc.
%#eml

eml_assert(isa(A,'float'), ...
    ['Function ''schur'' is not defined for values of class ''' class(A) '''.']);
eml_lib_assert(ndims(A) == 2, ...
    'EmbeddedMATLAB:schur:input2D', ...
    'Input must be 2-D.');
eml_lib_assert(size(A,1) == size(A,2), ...
    'MATLAB:square', ...
    'Matrix must be square');
eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin < 2
    if isreal(A)
        doreal = true;
    else
        doreal = false;
    end
else
    eml_assert(ischar(opt) &&  ...
        (strcmp(opt,'complex') || strcmp(opt,'real')), ...
        'Second argument must be ''real'' or ''complex''.');
    doreal = strcmp(opt,'real');
end
if nargout < 2
    if isreal(A)
        A = eml_xgehrd(A);
        if doreal
            [V,info]= eml_xhseqr(A);
        else
            [Vr,info]= eml_xhseqr(A);
            V = eml_rsf2csf(Vr);
        end
    else
        A = eml_xgehrd(A);
        [V,info]= eml_xhseqr(A);
    end
else
    n = cast(size(A,1),eml_index_class);
    ONE = ones(eml_index_class);
    [A,tau] = eml_xgehrd(A);
    if isreal(A)
        if doreal
            V = eml_xunghr(n,ONE,n,A,ONE,n,tau,ONE);
            [T,info,V]= eml_xhseqr(A,V);
        else
            Vr = eml_xunghr(n,ONE,n,A,ONE,n,tau,ONE);
            [Tr,info,Vr]= eml_xhseqr(A,Vr);
            [V,T] = rsf2csf(Vr,Tr);
        end
    else
        V = eml_xunghr(n,ONE,n,A,ONE,n,tau,ONE);
        [T,info,V]= eml_xhseqr(A,V);
    end
end
if info ~= 0
    eml_warning('EmbeddedMATLAB:schur:failed','SCHUR failed.');
end

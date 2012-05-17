function y = mean(x,dim)
%Embedded MATLAB Library Function.

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments');
eml_assert(isa(x,'numeric') || ischar(x) || islogical(x), ...
    ['Function ''mean'' is not defined for values of class ''' class(x) '''.']);
if nargin == 1
    if eml_is_const(size(x)) && isequal(x,[])
        % The output size for [] is a special case when DIM is not given.
        y = eml_guarded_nan(class(x));
        return
    end
    eml_lib_assert(eml_is_const(size(x)) || ~isequal(x,[]), ...
        'EmbeddedMATLAB:mean:specialEmpty', ...
        'MEAN with one variable-size matrix input of [] is not supported.');
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x,dim)) || ...
        isscalar(x) || ...
        size(x,dim) ~= 1, ...
        'EmbeddedMATLAB:sum:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end
if eml_is_const(size(x,dim)) && size(x,dim) == 1
    % No arithmetic will be done, but we still call
    % sum() to get the right output class.
    y = sum(x,dim);
    return
end
y = sum(x,dim) ./ size(x,dim);

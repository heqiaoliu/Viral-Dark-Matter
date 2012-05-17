function c = rdivide(a,b)
%./ Fixed point eML library function for rdivide
%
%    See also MRDIVIDE.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/11/13 04:16:47 $
%#eml

eml.extrinsic('eml_fi_computeDivideType');
eml_allow_mx_inputs;

eml_assert(isequal(size(a),size(b)) || ...
           isscalar(a) || ...
           isscalar(b),...
           'In A./B, A and B must have the same dimensions unless one is a scalar.');

if eml_ambiguous_types
    % Embedded MATLAB hasn't resolved the types yet, so return anything of
    % the right size
    if prod(size(a))>prod(size(b)) %#ok numel doesn't work for fi
        c = eml_not_const(zeros(size(a))); 
    else
        c = eml_not_const(zeros(size(b)));
    end
else
    eml_assert((isnumeric(a)&&isnumeric(b)),'Data must be numeric.');    
    eml_assert(isreal(b), ...
              'In A./B and A/B, the denominator B must be real if either A or B is a fi object.');

    % The numerictype of the output must be determined from const inputs.
    % If we had called the fi::computeDivideType method directy with inputs A
    % and B, then we would have got the error "This expression must be
    % constant because its value determines the size or class of some
    % expression." 
    if isfi(a)
        Ta = numerictype(a);
    else
        Ta = class(a);
    end
    if isfi(b)
        Tb = numerictype(b);
    else
        Tb = class(b);
    end
    [T, errid, errmsg] = eml_const(eml_fi_computeDivideType(Ta,Tb));
    eml_assert(isempty(errmsg), errmsg);
    c = divide(T,a,b);
end


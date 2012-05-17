%#eml
function c = eml_fixpt_times(a,b,tc,tp,f)
% Private eML fixed-point library function that does c = a.*b
% tc is the type of output c and tp is the product type and can
% be different from tc if a & b are complex. f is the fimath.

%   Copyright 2007-2009 The MathWorks, Inc.


eml_allow_mx_inputs;

% Check complexity of a & b
aIsReal = isreal(a); bIsReal = isreal(b);

if ~aIsReal && ~bIsReal
    ar = real(a); ai = imag(a);
    br = real(b); bi = imag(b);
    
    % Real part of the result = pr1-pr2
    pr1 = eml_times(ar,br,tp,f);
    pr2 = eml_times(ai,bi,tp,f);
    % xxx pre = eml_cast(eml_minus(pr1,pr2,tc,f),tp,f);
    % If castbeforesum = true cst pr1 & pr2 into the sum type 
    fullPrecSum = eml_const(strcmpi(get(f,'SumMode'),'FullPrecision'));
    cb4sum      = eml_const(get(f,'CastBeforeSum'));
    if fullPrecSum || cb4sum
      pr1in = eml_cast(pr1,tc,f);
      pr2in = eml_cast(pr2,tc,f);
    else
      pr1in = pr1;
      pr2in = pr2;
    end
    pre = eml_minus(pr1in,pr2in,tc,f);
    
    % Imag part of the result = pi1+pi2
    pi1 = eml_times(ar,bi,tp,f);
    pi2 = eml_times(ai,br,tp,f);
    % xxx pim = eml_cast(eml_plus(pi1,pi2,tc,f),tp,f);
    % If castbeforesum = true cast pi1 and pi2 into sum type
    if (cb4sum)
      pi1in = eml_cast(pi1,tc,f);
      pi2in = eml_cast(pi2,tc,f);
    else
      pi1in = pi1;
      pi2in = pi2;
    end
    pim = eml_plus(pi1in,pi2in,tc,f);
    
    c = eml_cast(complex(pre,pim),tc,f);
       
elseif ~aIsReal && bIsReal
    ar = real(a); ai = imag(a);
    cr = eml_times(ar,b,tc,f);
    ci = eml_times(ai,b,tc,f);
    c = complex(cr,ci);
    
elseif aIsReal && ~bIsReal
    br = real(b); bi = imag(b);
    cr = eml_times(a,br,tc,f);
    ci = eml_times(a,bi,tc,f);
    c = complex(cr,ci);
    
else % a and b are real
    % Call the eml_times after ain & bin and tc have been set up properly
    c = eml_times(a,b,tc,f);
    
end
%--------------------------------------------------------------------------


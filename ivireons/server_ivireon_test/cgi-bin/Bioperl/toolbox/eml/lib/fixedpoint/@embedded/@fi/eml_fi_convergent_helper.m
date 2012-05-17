function yreturn = eml_fi_convergent_helper(a)
%EML_FI_CONVERGENT_HELPER Internal use only function

%   Y = EML_FI_CONVERGENT_HELPER(A) performs MATLAB style 'convergent' on 
%   input fi object A and returns the result in fi object Y. 

% Copyright 2007-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:53:55 $

eml.extrinsic('eml_get_out_numerictype_for_round');
eml_allow_mx_inputs;
eml_assert(nargin == 1, 'Incorrect number of inputs.');

t_a = eml_typeof(a);

% Supported data types are fixed-point (binary point scaling), double
% or single. This function can handle fiBooleans though they are not 
% supported by EML at present. FiSingles and FiDoubles are not passed on 
% to this helper function.

afl = eml_const(t_a.fractionlength);
awl = eml_const(t_a.wordlength);
if ~(isboolean(a) ||isfixed(a))
    eml_fi_assert_dataTypeNotSupported(upper(str_rnd_type),...
        'fixed-point (binary point scaling), double, or single');    
end

eml_assert(~isslopebiasscaled(t_a), ...
    'Slope bias scaled inputs are not supported');

if isboolean(a) ||(isfixed(a)&&(afl <= 0))
    y = a;
else
    % a is fiFixed and its fractionlength is positive
    t_y = eml_const(eml_get_out_numerictype_for_round(t_a,1));
    f_y = eml_fimath(a);
    if (afl > awl)
        y = nearest(a);

    elseif isreal(a)
        y = fi(zeros(size(a)),t_y,f_y);        
        for k = 1:eml_numel(a)
            y(k) = scalar_convergent(a(k),t_y,afl);
        end        
    else
        y = fi(complex(zeros(size(a)), zeros(size(a))),t_y,f_y);   
        for k = 1:eml_numel(a)
            y(k) = complex(scalar_convergent(real(a(k)),t_y,afl),scalar_convergent(imag(a(k)),t_y,afl));
        end                
    end

end

% If the input is fimathless then the output should also be
if eml_const(eml_fimathislocal(a))
    yreturn = y;
else
    yreturn = eml_fimathislocal(y,false);
end

function v = scalar_convergent(u,t,ufl)

f = floor(u);
b = bitsliceget(u,ufl,1);

if b == (2^(ufl-1))    
    if getlsb(f) == 0
        v = eml_cast(f,t);
    else
        v1 = ceil(u);
        v = eml_cast(v1,t);
    end
else
    v2 = nearest(u);
    v = eml_cast(v2,t);
end


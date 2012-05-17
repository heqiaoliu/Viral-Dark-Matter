function yreturn = eml_fi_round_helper(a)
%EML_FI_ROUND_HELPER Internal use only function

%   Y = EML_FI_ROUND_HELPER(A) performs MATLAB style 'round' on 
%   input fi object A and returns the result in fi object Y. 

% Copyright 2007-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:53:57 $

eml.extrinsic('eml_get_out_numerictype_for_round');
eml_allow_mx_inputs;
eml_assert(nargin == 1, 'Incorrect number of inputs.');

t_a = eml_typeof(a);

% Supported data types are fixed-point (binary point scaling), double
% or single. This function can handle fiBooleans though they are not 
% supported by EML at present. FiSingles and FiDoubles are not passed on 
% to this helper function.

if ~(isboolean(a) ||isfixed(a))
    eml_fi_assert_dataTypeNotSupported(upper(str_rnd_type),...
        'fixed-point (binary point scaling), double, or single');    
end

eml_assert(~isslopebiasscaled(t_a), ...
    'Slope bias scaled inputs are not supported');

if isboolean(a) ||(isfixed(a)&&(t_a.fractionlength <= 0))
    y = a;
else
    % a is fiFixed and its fractionlength is positive
    t_y = eml_const(eml_get_out_numerictype_for_round(t_a,1));
    f_y = eml_fimath(a);
    if ~issigned(a)
        a1 = fi(a,'summode','keepMSB','sumwordlength',t_y.wordlength+1,'roundmode','floor');
        if isreal(a)
            y = eml_cast(floor(a1+0.5),t_y,f_y);
        else
            y = eml_cast(floor(a1+(0.5+0.5j)),t_y,f_y);            
        end
    elseif isreal(a)
        y = fi(zeros(size(a)),t_y,f_y);        
        for k = 1:eml_numel(a)
            y(k) = scalar_round(a(k),t_y,f_y);
        end        
    else
        y = fi(complex(zeros(size(a)), zeros(size(a))),t_y,f_y);   
        for k = 1:eml_numel(a)
            y(k) = complex(scalar_round(real(a(k)),t_y,f_y),scalar_round(imag(a(k)),t_y,f_y));
        end                
    end

end

% If the input is fimathless then the output should also be
if eml_const(eml_fimathislocal(a))
    yreturn = y;
else
    yreturn = eml_fimathislocal(y,false);
end

function v = scalar_round(u,t,f)

if u < 0
    u1 = fi(u,'summode','keepMSB','sumwordlength',t.wordlength+1,'roundmode','ceil');
    w1 = ceil(u1 - 0.5);
    v = eml_cast(w1,t,f);
else
    u2 = fi(u,'summode','keepMSB','sumwordlength',t.wordlength+1,'roundmode','floor');
    w2 = floor(u2 + 0.5);
    v = eml_cast(w2,t,f);
end

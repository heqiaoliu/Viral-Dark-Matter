function y = eml_fi_matlab_style_round_helper(a, str_rnd_type, num_bit_grow)
%EML_FI_MATLAB_STYLE_ROUND_HELPER Internal use only function

%   Y = EML_FI_MATLAB_STYLE_ROUND_HELPER(A, STR_RND_TYPE, NUM_BIT_GROW)
%   performs MATLAB style rounding on input fi object A and returns the 
%   result in fi object Y. 
%
%   The input string STR_RND_TYPE can be 'ceil', 'fix', 'floor' or 'nearest', 
%   depending on which the specific rounding method to be applied is selected.
%
%   NUM_BIT_GROW should be set to 1 if the rounding method specified is 
%   CEIL or NEAREST and to 0 if the rounding method specified is FIX or FLOOR.

% Copyright 2007-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2009/03/30 23:30:01 $

eml_prefer_const(num_bit_grow);

eml.extrinsic('eml_get_out_numerictype_for_round');
eml_allow_mx_inputs;
eml_assert(nargin == 3, 'Incorrect number of inputs.');

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
    t_y = eml_const(eml_get_out_numerictype_for_round(t_a,num_bit_grow));
    f_a = eml_fimath(a);
    orig_round_mode = f_a.roundmode;
    different_modes = ~strcmp(orig_round_mode,str_rnd_type);
    if different_modes
    	f_y = fimath(f_a,'roundmode',str_rnd_type);
    	y1 = eml_cast(a,t_y,f_y);
    	y = eml_fimathislocal(fi(y1,f_a),eml_fimathislocal(a));
    else
    	y = eml_fimathislocal(eml_cast(a,t_y,f_a),eml_fimathislocal(a));
    end
end

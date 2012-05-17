function y = rescale(x,varargin)
% Embedded MATLAB Library function.
%
%RESCALE  Change the scaling of a fixed-point number.
%   B = RESCALE(A, FractionLength)
%   B = RESCALE(A, Slope, Bias)
%   B = RESCALE(A, SlopeAdjustmentFactor, FixedExponent, Bias)
%   B = RESCALE(A, Parameter1,Value1, ...)
%   returns fi object B with the same stored-integer-value as A, but
%   with new scaling applied.  Only scaling parameters are allowed in
%   the parameter/value pairs.
%
%   RESCALE is similar to the FI copy constructor, except
%     (1) The FI constructor preserves the real-world-value, while RESCALE
%     preserves the stored-integer-value.
%     (2) RESCALE does not allow Signed and WordLength properties to be
%     changed.
%
%   Examples:
%
%     A = fi(10, 1, 8, 3);
%     B = rescale(A,1)
%     In this example, A's stored-integer-value is scaled by 2^-3, and 
%     B preserves the stored-integer-value of A, but changes the scaling to 2^-1. 
%     Thus, 
%       A has real-world-value 10 = (stored-integer-value 80)*2^-3
%       B has real-world-value 40 = (stored-integer-value 80)*2^-1

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.8 $  $Date: 2009/12/28 04:10:47 $

% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

% To check if Complex Slope-bias is disabled
eml.extrinsic('feature');
      
eml_assert(nargin >= 2, 'error', 'Not enough number of input arguments.');

if isfixed(x)
    % FI objects with Fixed datatype
    
    nNumerictypeVar = nargin-1;

    if eml_ambiguous_types
        tempout = zeros(size(x));
        if isreal(x)
            y = tempout;
        else
            y = complex(tempout,tempout);
        end
        return;
    elseif isfi(x)   
        % Check to see if x is a fi. If x is not a fi assert. 
        t_x    = eml_typeof(x);
        WL     = eml_const(get(t_x, 'WordLength'));
        s      = eml_const(get(t_x, 'Signed'));
        F      = fimath(x);
    else
        eml_assert(0,'Input data v in rescale(v,...) must be fi');
    end

    T1 = numerictype(s, WL,0);
    % Switch on the number of input arguments.
    switch nNumerictypeVar
      case 1 % rescale(A, fractionlength)
        T = numerictype(s,  WL, varargin{1});
      case 2 % rescale(A, Slope, Bias) or rescale(A, var1, var2)
             % Find the position of the first char argument, which indicates the
             % start of the parameter/value pairs.
        if ischar(varargin{1})
            T = numerictype(T1, varargin{1}, varargin{2});
        else
            T = numerictype(s, WL, varargin{1}, varargin{2});        
        end
      case 3 % rescale(A, SlopeAdjustmentFactor, FixedExponent, Bias)
        T = numerictype(s, WL, varargin{1}, varargin{2}, varargin{3});        
      otherwise
        T = numerictype(T1, varargin{:});
    end
    
    if eml_const(~isequal(T1.Signed,T.Signed))
        eml_assert(0,'Changing the signed is not allowed in RESCALE.');
    end
    
    if eml_const(~isequal(T1.WordLength,T.WordLength))
        eml_assert(0,'Changing the wordlength is not allowed in RESCALE.');
    end
    
    
    if eml_const(feature('FiRealOnlySlopeBias'))
        eml_assert((isreal(x)||~isslopebiasscaled(T)), ...
            'Complex FI objects must have an integer power of 2 slope, and a bias of 0.');
    end

    yHasLocalFimath = eml_const(eml_fimathislocal(x));
    if isreal(x)
        y = eml_fimathislocal(eml_dress(x,T,F),yHasLocalFimath);
    else
        yr = eml_dress(real(x),T,F);
        yi = eml_dress(imag(x),T,F);  
        y  = eml_fimathislocal(complex(yr, yi),yHasLocalFimath);
    end
    
    %if ~eml_const(eml_fimathislocal(x))
    %    y = eml_fimathislocal(ytemp,false);
    %else
    %    y = ytemp;
    %end
    
elseif isfloat(x)
    % True Double or True Single FI
    warnMsg = eml_const(['Cannot change the specified property when the data type mode is ' ...
                        'Double, Single, or Boolean. That property has not been changed.']);
    eml_assert(false,'warning',warnMsg);
    y = x;
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('RESCALE','fixed-point,double, or single');
end

%--------------------------------------------------

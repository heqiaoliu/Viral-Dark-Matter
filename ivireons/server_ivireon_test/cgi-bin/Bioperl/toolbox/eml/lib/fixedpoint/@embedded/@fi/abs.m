function yreturn = abs(xfi, var1, var2)
%ABS    Fixed-point abs function for Embedded MATLAB
%
%   ABS(A) will return the absolute value of real or complex input A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/abs.m $
% Copyright 2005-2010 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.12 $  $Date: 2010/05/20 02:16:08 $
% This function accepts mxArray input argument

eml.extrinsic('eml_fiabs_helper');
eml.extrinsic('strcmpi');
eml.extrinsic('emlGetNTypeForTimes');
eml.extrinsic('emlGetNTypeForPlus');
eml_allow_mx_inputs;      
eml_assert(~strcmp(eml.target(),'hdl') || isreal(xfi), ...
    'HDL code generation for complex data type is not supported for abs function');
if eml_ambiguous_types
    yreturn = eml_not_const(zeros(size(xfi)));
    return;
end

% Error if incorrect number of inputs
eml_assert(nargin >= 1 && nargin <= 3,'Incorrect number of inputs');
maxWL = eml_option('FixedPointWidthLimit');

if isfloat(xfi)
    
    fimathSpecified = false;
    
    % Parse the inputs
    switch nargin
        
      case 1 % abs(x)
        Ty = eml_const(eml_typeof(xfi));
        Fy = eml_const(eml_fimath(xfi));
        
      case 2 % abs(x,T) or abs(x,F) 
        eml_assert(eml_is_const(var1),'In abs(x,var1) var1 must be a constant');
        if isnumerictype(var1)
            Ty = localGetAbsNumericType(xfi,var1);
            Fy = eml_const(eml_fimath(xfi));
        elseif isfimath(var1)
            Ty = eml_const(eml_typeof(xfi));
            Fy = eml_const(var1);
        else
            eml_assert(false,'No method ''abs'' with matching signature found for class ''embedded.fi.''');
        end
        
      case 3 % abs(x,T,F) or abs(x,F,T)
        eml_assert(eml_is_const(var1) && eml_is_const(var2),...
                   'In abs(x,var1,var2) var1 and var2 must be constants');
        if isnumerictype(var1)&&isfimath(var2) % abs(x,T,F)
            Ty = localGetAbsNumericType(xfi,var1);
            Fy = eml_const(var2);            
        elseif isfimath(var1)&&isnumerictype(var2) % abs(x,F,T)   
            Ty = localGetAbsNumericType(xfi,var2);
            Fy = eml_const(var1);
        else 
            eml_assert(false,'No method ''abs'' with matching signature found for class ''embedded.fi.''');
        end
        
    end
    
    if localAbsIsDouble(Ty)||localAbsIsSingle(Ty)
        xfi_type = eml_cast(0,Ty);
        dType = eml_fi_getDType(xfi_type);
    else
        dType  = eml_fi_getDType(xfi);
    end
    
    xDType = eml_cast(xfi,dType);
    yDType = abs(xDType);
    y      = eml_cast(yDType,Ty,Fy);      
    
elseif isfixed(xfi)
    
    switch nargin

      case 1 % abs(x) 
        if eml_is_const(xfi)
            [Ty,Fy,fimathSpecified,errMsg] = eml_const(eml_fiabs_helper(xfi));
        else % ~eml_is_const(x)
            data = eml_cast(0,numerictype(xfi),fimath(xfi));
            [Ty,Fy,fimathSpecified,errMsg] = eml_const(eml_fiabs_helper(data));
        end

      case 2 % abs(x,T) or abs(x,F) 
        eml_assert(eml_is_const(var1),'In abs(x,var1) var1 must be a constant');
        if eml_is_const(xfi)
            [Ty,Fy,fimathSpecified,errMsg] = eml_const(eml_fiabs_helper(xfi,var1));
        else % ~eml_is_const(x)
            data = eml_cast(0,numerictype(xfi),fimath(xfi));
            [Ty,Fy,fimathSpecified,errMsg] = eml_const(eml_fiabs_helper(data,var1));
        end

      case 3 % abs(x,T,F) or abs(x,F,T)
        eml_assert(eml_is_const(var1) && eml_is_const(var2),...
                   'In abs(x,var1,var2) var1 and var2 must be constants');
        if eml_is_const(xfi)
            [Ty,Fy,fimathSpecified,errMsg] = eml_const(eml_fiabs_helper(xfi,var1,var2));
        else % ~eml_is_const(x)
            data = eml_cast(0,numerictype(xfi),fimath(xfi));
            [Ty,Fy,fimathSpecified,errMsg] = eml_const(eml_fiabs_helper(data,var1,var2));
        end

    end
    
    eml_assert(isempty(errMsg),errMsg);

    if isreal(xfi)
        % compute abs of real input
        if localAbsIsDouble(Ty)||localAbsIsSingle(Ty)
            % handle the case where input is of datatype fixed but inferred
            % numerictype is of datatype float
            y = localAbsToFloat(xfi,Ty,Fy);            
            
        else
            y = eml_cast(zeros(size(xfi)),Ty,Fy);
            numelx = eml_numel(xfi);
            for k = 1:numelx
                if xfi(k) < 0
                    y(k) = eml_uminus(xfi(k),Ty,Fy);  
                else
		    y(k) = eml_cast(xfi(k),Ty,Fy);
                end
            end 

        end

    else
        % compute abs of complex input
        if isboolean(xfi)||eml_const(strcmpi(get(Ty, 'DataType'), 'boolean'))
            eml_assert(false,'The abs function does not support complex fi objects when the fi object or the specified numerictype object is Boolean.');
        end
        
        fullPrecSum = eml_const(strcmpi(get(Fy,'SumMode'),'FullPrecision'));
        cb4sum      = eml_const(get(Fy,'CastBeforeSum'));
        if ~(fullPrecSum || cb4sum)
            eml_assert(false,'fi math operations require CastBeforeSum to be true when SumMode is not FullPrecision');
        end
        if localAbsIsDouble(Ty)||localAbsIsSingle(Ty)
            % handle the case where input is of datatype fixed but inferred
            % numerictype is of datatype float
            y = localAbsToFloat(xfi,Ty,Fy);            
            
        else
            % handle the case where input and inferred numerictype are of
            % datatype fixed 
            tin = numerictype(xfi);
            xfi_re = fi(real(xfi),tin,Fy);
            xfi_im = fi(imag(xfi),tin, Fy);
            
            [tp, errmsg] = eml_const(emlGetNTypeForTimes(tin,tin,Fy,true,true,maxWL));
            if ~isempty(errmsg)
                eml_assert(false,errmsg);
            end
            xfi_re_sq = eml_times(xfi_re,xfi_re,tp,Fy);
            xfi_im_sq = eml_times(xfi_im,xfi_im,tp,Fy);
            if issigned(xfi)
                tpu = numerictype(false,tp.wordlength,tp.fractionlength);

                xfi_re_sqU = eml_reinterpretcast(xfi_re_sq,tpu);
                xfi_im_sqU = eml_reinterpretcast(xfi_im_sq,tpu);

                ts = eml_const(emlGetNTypeForPlus(tpu,tpu,Fy,maxWL));   
                xfi_abs_sq = eml_plus(xfi_re_sqU,xfi_im_sqU,ts,Fy);    

            else
                ts = eml_const(emlGetNTypeForPlus(tp,tp,Fy,maxWL));   
                xfi_abs_sq = eml_plus(xfi_re_sq,xfi_im_sq,ts,Fy);     
            end
            y = sqrt(xfi_abs_sq,Ty,Fy); 
       
        end
    end    
else

    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('ABS','fixed-point, double, or single');    
    
end

% If the input fi does not have an attached fimath, then the output doesn't either
if eml_const(~eml_fimathislocal(xfi)) || fimathSpecified
    yreturn = eml_fimathislocal(y,false);
else
    yreturn = eml_cast(eml_fimathislocal(y,true),numerictype(y),fimath(xfi));
end

%--------------------------------------------------------------------------------
function Ty = localGetAbsNumericType(x,T)
% Returns numerictype of output. This local function should
% be used only when input x is a float fi. The output, Ty is const.

eml_transient;

if (eml_const(isnumerictype(T)) && (localAbsIsSingle(T) || localAbsIsDouble(T)))
    % NumericType is float (double/single)
    Ty = eml_const(T);
else
    Ty = eml_const(eml_typeof(x));
end

%--------------------------------------------------------------------------

function bOut = localAbsIsSingle(T)
eml.extrinsic('strcmpi');
eml_transient;

bOut = eml_const(strcmpi(get(T, 'DataType'), 'Single'));

%--------------------------------------------------------------------------

function bOut = localAbsIsDouble(T)
eml.extrinsic('strcmpi');
eml_transient;

bOut = eml_const(strcmpi(get(T, 'DataType'), 'Double'));

%--------------------------------------------------------------------------

function y = localAbsToFloat(xfi,Ty,Fy)

xfi_type = eml_cast(0,Ty);
dType = eml_fi_getDType(xfi_type);
xDType = eml_cast(xfi,dType);
yDType = abs(xDType);
y = eml_cast(yDType,Ty,Fy);      

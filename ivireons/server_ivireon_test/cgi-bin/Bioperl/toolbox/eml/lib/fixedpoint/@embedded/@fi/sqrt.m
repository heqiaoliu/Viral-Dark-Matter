function yreturn = sqrt(x,var1,var2)
% SQRT Fixed-point square root function for Embedded MATLAB

% Copyright 2006-2010 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.13 $  $Date: 2010/04/05 22:15:14 $

eml.extrinsic('eml_fisqrt_helper');
    
% This function accepts mxArray input argument
eml_allow_mx_inputs;      

if eml_ambiguous_types
    yreturn = eml_not_const(zeros(size(x)));
    return;
end

% Error if incorrect number of inputs
eml_assert(nargin >= 1 && nargin <= 3,'Incorrect number of inputs');

% Error if complex, or slope bias or negative
eml_assert(isreal(x),'The sqrt function is not supported for complex fi.');

%

if isfixed(x)
    % FI objects with Fixed datatype

    % Parse the inputs
    switch nargin
      case 1 % sqrt(x) get Ty and Fy and method = bisection

        if eml_is_const(x)
            [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_const(eml_fisqrt_helper(x));
        else % ~eml_is_const(x)
            data = localGetConstX(x);
            [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_const(eml_fisqrt_helper(data));
        end
        eml_assert(isempty(errMsg),errMsg);
        
      case 2 % sqrt(x,T), sqrt(x,F) or sqrt(x,method)
        eml_assert(eml_is_const(var1),'In sqrt(x,var1) var1 must be a constant');
        if eml_is_const(x)
            [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_const(eml_fisqrt_helper(x,var1));
        else % ~eml_is_const(x)
            data = localGetConstX(x);
            [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_const(eml_fisqrt_helper(data,var1));
        end
        eml_assert(isempty(errMsg),errMsg);
        
      case 3 % sqrt(x,T,F), sqrt(x,T,method) or sqrt(x,F,method)
        eml_assert(eml_is_const(var1) && eml_is_const(var2),...
                   'In sqrt(x,var1,var2) var1 and var2 must be constants');
        if eml_is_const(x)
            [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_const(eml_fisqrt_helper(x,var1,var2));
        else % ~eml_is_const(x)
            data = localGetConstX(x);
            [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_const(eml_fisqrt_helper(data,var1,var2));
        end
        eml_assert(isempty(errMsg),errMsg);
        
    end

    % Error if x or Ty is slope-bias scaled
    if (isslopebiasscaled(numerictype(x)) || isslopebiasscaled(Ty))
        eml_assert(0,['sqrt(A) or sqrt(A,T) can only be calculated ',...
                      'for FI object A  and NumericType T when the scaling ',...
                      'of A and T has a fractional slope of 1 ',...
                      'and 0 bias (binary-point only scaling).']);
    end

    % Initialize output y with Ty and Fy to prevent compiler error
    y = fi(zeros(size(x)),Ty,Fy);

    % Compute sqrt based on the square root method
    switch methodName
      case 0 % bisection 
        y = bisectionSqrt(x,y,Ty,Fy);
    end

elseif isfloat(x)
    % True Double or True Single FI
    fimathSpecified = eml_const(false);
    % Parse the inputs
    switch nargin
      case 1 % sqrt(x)
        Ty = eml_const(eml_typeof(x));
        Fy = eml_const(eml_fimath(x));
      case 2 % sqrt(x,T), sqrt(x,F) or sqrt(x,method)->This syntax is not yet
             % supported, hence error out
        eml_assert(eml_is_const(var1),'In sqrt(x,var1) var1 must be a constant');
        if isnumerictype(var1)
            Ty = localGetSqrtNumericType(x,var1);
            Fy = eml_const(eml_fimath(x));
        elseif isfimath(var1)
            Ty = eml_const(eml_typeof(x));
            Fy = eml_const(var1);
        else
            eml_assert(false,'No method ''sqrt'' with matching signature found for class ''embedded.fi.''');
        end
        
      case 3 % sqrt(x,T,F), sqrt(x,T,method) or sqrt(x,F,method)
        eml_assert(eml_is_const(var1) && eml_is_const(var2),...
                   'In sqrt(x,var1,var2) var1 and var2 must be constants');
        if ischar(var2) % sqrt(x,T,method) or sqrt(x,F,method)
            if isnumerictype(var1)
                Ty = localGetSqrtNumericType(x,var1);
                Fy = eml_const(eml_fimath(x));
            elseif isfimath(var1)
                Ty = eml_const(eml_typeof(x));
                Fy = eml_const(var1);
            else
                eml_assert(false,'No method ''sqrt'' with matching signature found for class ''embedded.fi.''');
            end
        else % sqrt(x,T,F)
            Ty = localGetSqrtNumericType(x,var1);
            Fy = eml_const(var2);
        end
    end

    % Call MATLAB realsqrt as complex inputs are not supported.
    dType  = eml_fi_getDType(x);
    xDType = eml_cast(x,dType);
    yDType = realsqrt(xDType);
    y      = eml_cast(yDType,Ty,Fy);    
    
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('SQRT','fixed-point,double, or single');
end

% If the input fi does not have an attached fimath, then the output doesn't either
% Also if a fimath is specified as one of the input parameters, the output is then fimathless.
if eml_const(~eml_fimathislocal(x)) || fimathSpecified
    yreturn = eml_fimathislocal(y,false);
else
    yreturn = y;
end


%---------------------------------------------------------------------------------
function y = bisectionSqrt(x,yinit,Ty,Fy)

eml.extrinsic('emlGetNTypeForTimes');
eml.extrinsic('eml_iscomplexroundmode_helper');

% Binary search method of finding the square root

% This function accepts mxArray input argument
eml_allow_mx_inputs;      

% Get numel of x
Nx = eml_numel(x);

% Initialize y 
y = yinit;
maxWL = eml_option('FixedPointWidthLimit');

% Initialize other temporary variables
[Tsquare,errmsg1]  = eml_const(emlGetNTypeForTimes(Ty,Ty,Fy,true,true,maxWL));
if ~isempty(errmsg1)
    eml_assert(0,errmsg1);
end
wlTsquare = eml_const(get(Tsquare,'WordLength'));
flTsquare = eml_const(get(Tsquare,'FractionLength'));
yWL = eml_const(get(Ty,'WordLength'));
yFL = eml_const(get(Ty,'FractionLength'));

Ftemp = fimath(Fy,'ProductMode','SpecifyPrecision',...
               'ProductWordLength',wlTsquare,...
               'ProductFractionLength',flTsquare,...
               'SumMode','SpecifyPrecision',...
               'SumWordLength',wlTsquare,...
               'SumFractionLength',flTsquare,...
               'CastBeforeSum',true);
FtempForPlusLSB = fimath(Fy,'ProductMode','SpecifyPrecision',...
                         'ProductWordLength',wlTsquare,...
                         'ProductFractionLength',flTsquare,...
                         'SumMode','SpecifyPrecision',...
                         'SumWordLength',yWL,...
                         'SumFractionLength',yFL,...
                         'CastBeforeSum',true);
ytemp = fi(0,Ty,FtempForPlusLSB);
lsbY = lsb(ytemp);
ytempSquare = fi(0,Tsquare,Ftemp);
ytempPlusLsb = fi(0,Ty,Ftemp);
ytempPlusLsbSquare = fi(0,Tsquare,Ftemp);
tempx = fi(0,numerictype(x),Ftemp);

% Determine bit location 
wlTy = eml_const(int32(get(Ty,'WordLength')));
if issigned(y)
    wn = wlTy - 1;
else    
    wn = wlTy;
end

% Compute output y
for k = 1:Nx
    % If x is negative y is 0, otherwise y is computed
    % Note: The embedded.fi::sqrt errors out for x < 0
    % eML cannot error out because it produces code and
    % a C run time error is not useful.
    if (x(k) <= 0)
        y(k) = 0;
    else

        % Find y(k)
        for i=wn:-1:1
            ytemp(1) = bitset(y(k),i);
            ytempSquare(1) = ytemp.*ytemp;
            if (ytempSquare <= x(k))
                y(k) = ytemp;
            end
        end
        % "Polish" the final result only when roundmode
        % is ceil, round, nearest or convergent
        if (eml_const(eml_iscomplexroundmode_helper(Fy)))

            if (y(k) < realmax(y))

                ytemp(1) = y(k);
                ytempSquare(1) = ytemp.*ytemp;
                ytempPlusLsb(1) = ytemp+lsbY;
                tempx(1) = x(k);
                if (eml_const(eml_iscomplexroundmode_helper(Fy,'ceil')))

                    if (ytempSquare < tempx)
                        y(k) = ytempPlusLsb;
                    end
                else % for round, nearest or convergent
                    
                    ytempPlusLsbSquare(1) = ytempPlusLsb*ytempPlusLsb;

                    if ( ytempPlusLsbSquare-tempx < tempx-ytempSquare)
                        y(k) = ytempPlusLsb;
                    end
                
                end
            end

        end
    end
end

%--------------------------------------------------------------------------------
function data = localGetConstX(x)
% Local function to return a const fi with same type and fimath as x

data = eml_cast(0,numerictype(x),fimath(x));

%--------------------------------------------------------------------------------
function Ty = localGetSqrtNumericType(x,T)

eml.extrinsic('strcmpi');

% Returns numerictype of output of sqrt function. This local function should
% be used only when input x is a float fi. The output, Ty is const.

eml_transient;

if ( eml_const(isnumerictype(T)) && eml_const(isfloat(T)) )
    % NumericType is float (double/single)
    Ty = eml_const(T);
else
    Ty = eml_const(eml_typeof(x));
end

%--------------------------------------------------------------------------------

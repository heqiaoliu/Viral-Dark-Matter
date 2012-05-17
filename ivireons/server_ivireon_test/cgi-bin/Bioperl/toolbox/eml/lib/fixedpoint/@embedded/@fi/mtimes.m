function cout = mtimes(a0,b0)
% Embedded MATLAB function the @fi/mtimes operation

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/mtimes.m
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.20 $  $Date: 2009/12/28 04:10:57 $

eml_assert(nargin == 2, 'Not enough input arguments.');
eml.extrinsic('emlGetBestPrecForMxArray');
eml.extrinsic('emlGetNTypeForTimes');
eml.extrinsic('emlGetNTypeForMTimes');
eml.extrinsic('eml_fi_math_with_same_types');

eml_allow_mx_inputs;
% Check for ambiguous types and return with the correct size output
if eml_ambiguous_types && (isfi(a0) || isfi(b0))
  rowA = size(a0,1); colB = size(b0,2);
  iscoutReal = isreal(a0) && isreal(b0);
  couttemp = zeros(rowA,colB);
  if iscoutReal
      cout = eml_not_const(couttemp);
  else
      cout = eml_not_const(complex(couttemp,couttemp));
  end
  return;
end

if (isscalar(a0)&&eml_is_const(isscalar(a0))) || (isscalar(b0)&&eml_is_const(isscalar(b0)))
    if ~isfi(b0) % fi * non-fi
        ta = eml_typeof(a0);
        biasA     = eml_const(get(ta,'Bias'));
        non_zero_Bias = (biasA~=0);
        safA      = eml_const(get(ta,'SlopeAdjustmentFactor'));
        non_trivial_SAF = (safA~=1);
    elseif ~isfi(a0) % non-fi * fi
        tb = eml_typeof(b0);
        biasB     = eml_const(get(tb,'Bias'));
        non_zero_Bias = (biasB~=0);
        safB      = eml_const(get(tb,'SlopeAdjustmentFactor'));
        non_trivial_SAF = (safB~=1);
    else
        ta = eml_typeof(a0);
        tb = eml_typeof(b0);
        biasA     = eml_const(get(ta,'Bias'));
        biasB     = eml_const(get(tb,'Bias'));
        safA      = eml_const(get(ta,'SlopeAdjustmentFactor'));
        safB      = eml_const(get(tb,'SlopeAdjustmentFactor'));
        non_zero_Bias = (biasA~=0)||(biasB~=0);
        non_trivial_SAF = (safA~=1)||(safB~=1);
    end
    isslopebias_in = non_zero_Bias||non_trivial_SAF;
    iscomplex_in   = ~isreal(a0) || ~isreal(b0);
      
    eml_assert(eml_const((isslopebias_in&&iscomplex_in)==0),...
             'Function ''mtimes'' is only supported for complex-value FI objects that have an integer power of 2 slope, and a bias of 0.');
    cout = times(a0,b0);
else
  
  eml_lib_assert(size(a0,2)==size(b0,1),'fixedpoint:fi:dimagree','Inner matrix dimensions must agree.');
  eml_assert(ndims(a0)<=2 && ndims(b0)<=2,'Input arguments must be 2-D');
  maxWL = eml_option('FixedPointWidthLimit');
  
  if ( (isfi(a0) && isfixed(a0)) || ...
       (isfi(b0) && isfixed(b0)) )
      % Fixed FI

      if ~isfi(b0) % fi * non-fi
          ta = eml_typeof(a0);

          % Get best precision numerictype for b
          eml_assert(eml_is_const(b0),'In fi * non-fi, the non-fi must be a constant.');
          eml_assert(isnumeric(b0),'Data must be numeric.');
          tb = eml_const(emlGetBestPrecForMxArray(b0,ta));
          f = eml_fimath(a0);
          a = a0; b = eml_cast(b0,tb,f);
          cHasLocalFimath = eml_const(eml_fimathislocal(a0));
      elseif ~isfi(a0) % non-fi * fi
          tb = eml_typeof(b0);

          % Get best precision numerictype for a
          eml_assert(eml_is_const(a0),'In non-fi * fi, the non-fi must be a constant.');
          eml_assert(isnumeric(a0),'Data must be numeric.');
          ta = eml_const(emlGetBestPrecForMxArray(a0,tb));
          f = eml_fimath(b0);
          b = b0; a = eml_cast(a0,ta,f);
          cHasLocalFimath = eml_const(eml_fimathislocal(b0));
      else % fi * fi
           % Obtain the numerictypes of a0 & b0
          ta = eml_typeof(a0); tb = eml_typeof(b0);

          % Verify that the datatypes are the same
          % - Scaled-type with floating not allowed
          % - Single with Double not allowed
          [ERR,a2SD,b2SD,Tsd] = eml_const(eml_fi_math_with_same_types(ta,tb));
          eml_assert(isempty(ERR),ERR);
          
          % Get the fimaths
          fa = eml_fimath(a0); fb = eml_fimath(b0); 
          
          % Check the fimaths and determine the output fimath
          [f,cHasLocalFimath] = eml_checkfimathforbinaryops(a0,b0);
          
          % Check if a or b have to cast into scaled-doubles
          if a2SD
              a = eml_cast(a0,Tsd,fa);
          elseif b2SD
              b = eml_cast(b0,Tsd,fb);
          else
              a = a0; b = b0;
          end
          
      end
      
      % Get the product type tc
      aIsReal = isreal(a); bIsReal = isreal(b);
      [rowsA, colsA] = size(a); colsB = double(size(b,2));

      [tp,errmsg1] = eml_const(emlGetNTypeForTimes(ta,tb,f,true,true,maxWL));
      if ~isempty(errmsg1)
          eml_assert(0,errmsg1);
      end
      
      if eml_is_const(size(a))
          [tc,errmsg2] = eml_const(emlGetNTypeForMTimes(ta,tb,f,aIsReal,bIsReal,colsA,true,maxWL));
          if ~isempty(errmsg2)
              eml_assert(0,errmsg2);
          end
      else
          % When input sizes can change at run-time, we only allow SumModes
	  % 'KeepLSB' and 'SpecifyPrecision'; For these two modes the output
	  % NumericType does not depend on the inner matrix dimension; we pass 2 as a
	  % dummy inner matrix dimension argument
          [tc,errmsg2] = eml_const(emlGetNTypeForMTimes(ta,tb,f,aIsReal,bIsReal,2,false,maxWL));
          if ~isempty(errmsg2)
              eml_assert(0,errmsg2);
          end
      end
      % Check for the SlopeBias mode, complex inputs are not supported in this case
      biasA     = eml_const(get(ta,'Bias'));
      biasB     = eml_const(get(tb,'Bias'));
      non_zero_Bias = (biasA~=0)||(biasB~=0);
      
      safA      = eml_const(get(ta,'SlopeAdjustmentFactor'));
      safB      = eml_const(get(tb,'SlopeAdjustmentFactor'));
      non_trivial_SAF = (safA~=1)||(safB~=1);
      
      isslopebias_in = non_zero_Bias||non_trivial_SAF;
      iscomplex_in   = ~isreal(a0) || ~isreal(b0);
      
      eml_assert(eml_const((isslopebias_in&&iscomplex_in)==0),...
                 'Function ''mtimes'' is only supported for complex-value FI objects that have an integer power of 2 slope, and a bias of 0.');
      
      fullPrecSum = eml_const(strcmpi(get(f,'SumMode'),'FullPrecision'));
      cb4sum      = eml_const(get(f,'CastBeforeSum'));
      if ~(fullPrecSum || cb4sum)
          eml_assert(0,'fi math operations require CastBeforeSum to be true when SumMode is not FullPrecision');
      end
      
      
      if aIsReal && bIsReal
          c = eml_cast(zeros(rowsA,colsB),tc,f);
      else
          cd = complex(zeros(rowsA,colsB),zeros(rowsA,colsB));  
          c = eml_cast(cd,tc,f);
      end
      
      for l =1:rowsA
          for m = 1:colsB
              for k = 1:colsA
                  % c(l,m) = c(l,m)+(a(l,k).*b(k,m));
                  % If a & b are real then assignment_type = product_type = tp
                  % If a & b are complex then assignment_type = sum_type:
                  % tc and product_type is tp
                  if aIsReal || bIsReal
                      prodAB = eml_fixpt_times(a(l,k),b(k,m),tp,tp,f);
                  else
                      prodAB = eml_fixpt_times(a(l,k),b(k,m),tc,tp,f);
                  end
                  c(l,m) = eml_plus(c(l,m),prodAB,tc,f); 
              end
          end
      end
      if ~cHasLocalFimath
          cout = eml_fimathislocal(c,false);
      else
          cout = c;
      end
      
  elseif ( isfi(a0) && isfloat(a0) ) || ...
          ( isfi(b0) && isfloat(b0) )
      % True Double or True Single FI

      % call ML mtimes directly
      check4constNonFI   = false; % non-FI need not be constant
      check4numericData  = true;  % non-FI must be numeric
      check4sameDatatype = true;  % The datatypes of two inputs must be same
      [ain,bin]          = eml_fi_cast_two_inputs(a0,b0,'.*',check4constNonFI,...
                                                  check4numericData,check4sameDatatype);
      [t,f]              = eml_fi_get_numerictype_fimath(a0,b0);
      
      c = ain * bin;
      cout = eml_cast(c,t,f);
      
  else
      % FI datatype not supported
      eml_fi_assert_dataTypeNotSupported('MTIMES','fixed-point,double, or single');
  end
  
end

%-------------------------------------------------------------------------------------------------------------

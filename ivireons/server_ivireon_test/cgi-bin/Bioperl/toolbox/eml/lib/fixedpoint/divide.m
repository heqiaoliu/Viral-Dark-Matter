function c = divide(tc,a0,b0)
% Embedded MATLAB function the fi/numerictype divide operation

% $INCLUDE(DOC) toolbox/eml/lib/dsp/divide.m $
% Copyright 2002-2010 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.10 $  $Date: 2010/04/05 22:15:07 $

eml.extrinsic('emlGetBestPrecForMxArray');
eml.extrinsic('strcmpi');  
eml_allow_mx_inputs;

% Check for nargin and assert if not 3
eml_assert(nargin==3,'Not enough input arguments.');

% Verify that the first input is an embedded.numerictype, is not slope/bias scaled, and has Signed and Scaling specified.
eml_assert(isnumerictype(tc),['Function divide is not defined for first argument of class ', class(tc), '. It must be an embedded.numerictype.']);

eml_assert((isreal(a0)&&isreal(b0))||(~isslopebiasscaled(tc)), ... 
               ['All complex FI objects created by Fixed-Point' ...
                   ' Toolbox operations must have an integer power '...
                   'of 2 slope, and a bias of 0.']);

% Verify that tc is not slope-bias scaled
eml_assert(~isslopebiasscaled(tc),'Function DIVIDE is only supported for FI object operands that have an integer power of 2 slope, and a bias of 0.');

% Verify that the signedness of tc is not auto
eml_assert(~eml_const(strcmpi(get(tc,'Signedness'),'Auto')),...
           'DIVIDE(T,A,B) is only supported when the SIGNEDNESS of NUMERICTYPE object T is SIGNED or UNSIGNED.');

% Verify that the scaling of tc is not unspecified
eml_assert(~tc.isscalingunspecified, ...
           'divide(T,A,B) is not supported when numerictype T has unspecified scaling.');

% Verify that a0 and b0 must be numeric
eml_assert(isnumeric(a0),'In divide(T,a,b) a must be numeric.');
eml_assert(isnumeric(b0),'In divide(T,a,b) b must be numeric.');

% Check for ambiguous types and return with the correct size output
if eml_ambiguous_types && ~isfi(a0) && ~isfi(b0) 
    c = eml_rdivide(a0,b0);
    return;
elseif eml_ambiguous_types && (isfi(a0) || isfi(b0))
    numelA = prod(size(a0)); numelB = prod(size(b0));
    if isfi(a0)
        ftemp = eml_fimath(a0);
    elseif isfi(b0)
        ftemp = eml_fimath(b0);
    end
    
    if numelA > numelB
        c = eml_cast(a0,tc,ftemp);
    else
        c = eml_cast(b0,tc,ftemp);
    end
    return;
end

if ( (isfi(a0) && isfixed(a0)) || ...
     (isfi(b0) && isfixed(b0)) )
    % Fixed FI

    % xxx Add code to parse through the inputs tc, a0 & b0 and error if necessary
    if isfi(a0) && ~isfi(b0) % fi ./ non-fi
        ta = eml_typeof(a0);
        % Verify that scaling is not slope-bias
        biasA = eml_const(get(ta,'Bias'));
        safA      = eml_const(get(ta,'SlopeAdjustmentFactor'));
        isslopebias_a = eml_const((biasA~=0)||(safA~=1));        
        eml_assert(eml_const(isslopebias_a==0),'Function DIVIDE is only supported for FI object operands that have an integer power of 2 slope, and a bias of 0.'); 
        % Get best precision numerictype for b
        eml_assert(eml_is_const(b0),'In divide(t,fi,non-fi), the non-fi must be a constant.');
        tb = eml_const(emlGetBestPrecForMxArray(b0,ta));
        f = eml_fimath(a0);
        eml_check_div_fimath(f);
        a = a0; b = eml_cast(b0,tb,f);
        cHasLocalFimath = eml_const(eml_fimathislocal(a0));
    elseif ~isfi(a0) && isfi(b0) % non-fi ./ fi
        tb = eml_typeof(b0);
        % Verify that scaling is not slope-bias
        biasB = eml_const(get(tb,'Bias'));
        safB      = eml_const(get(tb,'SlopeAdjustmentFactor'));
        isslopebias_b = eml_const((biasB~=0)||(safB~=1));        
        eml_assert(eml_const(isslopebias_b==0),'Function DIVIDE is only supported for FI object operands that have an integer power of 2 slope, and a bias of 0.');         
        % Get best precision numerictype for a
        eml_assert(eml_is_const(a0),'In divide(t,non-fi,fi), the non-fi must be a constant.');
        ta = eml_const(emlGetBestPrecForMxArray(a0,tb));
        f = eml_fimath(b0);
        eml_check_div_fimath(f);
        b = b0; a = eml_cast(a0,ta,f);
        cHasLocalFimath = eml_const(eml_fimathislocal(b0));
    elseif ~isfi(a0) && ~isfi(b0)  %%ck: is this redundant? is both are
                                   %non-fi, this fcn would not be called!
        c = eml_rdivide(a0,b0);
        return;
    else % fi ./ fi
         % Obtain the eml_typeofs of a & b
        ta = eml_typeof(a0); tb = eml_typeof(b0);
        % Verify that scalings are not slope-bias
        biasA = eml_const(get(ta,'Bias'));
        safA      = eml_const(get(ta,'SlopeAdjustmentFactor'));        
        biasB = eml_const(get(tb,'Bias'));
        safB      = eml_const(get(tb,'SlopeAdjustmentFactor'));
        isslopebias_a_or_b = eml_const((biasA~=0)||(safA~=1)||(biasB~=0)||(safB~=1));        
        eml_assert(eml_const(isslopebias_a_or_b==0),'Function DIVIDE is only supported for FI object operands that have an integer power of 2 slope, and a bias of 0.');
        % Get the fimath
        % Check the fimathislocal property and determine the output fimath
        aHasLocalFimath = eml_const(eml_fimathislocal(a0));
        bHasLocalFimath = eml_const(eml_fimathislocal(b0));
        f = eml_fimath(a0); % divide always takes A's fimath
        cHasLocalFimath = eml_const(aHasLocalFimath || bHasLocalFimath);
        eml_check_div_fimath(f);
        a = a0; b = b0;
    end

    if ~isreal(a) && isreal(b) % complex/real
        reala = real(a); imaga = imag(a);
        realc = eml_rdivide(reala,b,tc,f);
        imagc = eml_rdivide(imaga,b,tc,f);
        c = eml_fimathislocal(complex(realc,imagc),cHasLocalFimath);
    elseif ~isreal(b) % complex/complex & real/complex
        eml_assert(0,'Fixed-point divide is not supported in Embedded MATLAB when the divisor is complex.');
    else % real/real
         % tc is the numerictype of the divide
         % Call the eml_rdivide function with a,b,td and f
        c = eml_fimathislocal(eml_rdivide(a,b,tc,f),cHasLocalFimath);
    end
    %if eml_const(~cHasLocalFimath)
    %    c = eml_fimathislocal(c1,false);
    %else
    %    c = c1;
    %end
elseif ( isfi(a0) && isfloat(a0) ) || ...
        ( isfi(b0) && isfloat(b0) )
    % True Double or True Single FI

    % call MATLAB divide directly
    check4constNonFI   = false; % non-FI need not be constant
    check4numericData  = true;  % non-FI must be numeric
    check4sameDatatype = false; % The datatypes of two inputs need not be
                                % same
                                % As check4constNonFI = false, the operation name (third input argument)
                                % will not be used
    [ain,bin]          = eml_fi_cast_two_inputs(a0,b0,'dummy',check4constNonFI,...
                                                check4numericData,check4sameDatatype);
    [t,f]              = eml_fi_get_numerictype_fimath(a0,b0);

    if ~isreal(a0) && isreal(b0) % complex/real
        reala = real(ain); imaga = imag(ain);
        realc = eml_rdivide(reala,bin,t,f);
        imagc = eml_rdivide(imaga,bin,t,f);
        c = complex(realc,imagc);
    elseif ~isreal(b0) % complex/complex & real/complex
        eml_assert(0,'Fixed-point divide is not supported in Embedded MATLAB when the divisor is complex.');
    else % real/real
         % tc is the numerictype of the divide
         % Call the eml_rdivide function with a,b,td and f
        c = eml_rdivide(ain,bin,t,f);
    end
    
elseif isfloat(a0) || isfloat(b0)
    
    % call MATLAB divide directly
    c = eml_rdivide(a0,b0);

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('DIVIDE','fixed-point, double, or single');
end

%--------------------------------------------------------------------------------------------

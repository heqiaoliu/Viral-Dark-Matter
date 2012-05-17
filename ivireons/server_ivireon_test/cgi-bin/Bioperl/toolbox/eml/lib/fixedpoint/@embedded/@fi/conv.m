function Cout = conv(A0,B0,shape)
%CONV   Fixed-point convolution function for Embedded MATLAB
%
%   CONV(U,V) will return the result of convolving vector U with vector V.

%   Copyright 2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_lib_assert(isvector(A0) && isvector(B0), ...
    'MATLAB:conv:AorBNotVector', ...
   'A and B must be vectors.');
eml_assert(~(isfi(A0)&&isslopebiasscaled(numerictype(A0))),'Inputs to ''conv'' that are FI objects must have an integer power of 2 slope, and a bias of 0.');
eml_assert(~(isfi(A0)&&isboolean(A0))&&~(isfi(B0)&&isboolean(B0)),'Function ''conv'' not defined for FI objects of type ''boolean''.');
eml_assert(~(isfi(B0)&&isslopebiasscaled(numerictype(B0))),'Inputs to ''conv'' that are FI objects must have an integer power of 2 slope, and a bias of 0.');
eml_assert(~(isfi(B0)&&isboolean(B0)),'Function ''conv'' not defined for FI objects of type ''boolean''.');
eml_lib_assert(is_const_vector(A0)&&is_const_vector(B0)&&isnumeric(A0)&&isnumeric(B0),...
    'fi:conv:inputsMustBeVectors','Inputs to ''conv'' must be numeric vectors.');
eml.extrinsic('emlGetNTypeForMTimes');
eml.extrinsic('emlGetNTypeForTimes');
eml.extrinsic('eml_fi_math_with_same_types');
eml.extrinsic('emlGetBestPrecForMxArray');
eml_allow_mx_inputs;

if eml_ambiguous_types && (isfi(A0) || isfi(B0))
    
  Cref = conv(double(A0),double(B0));
  szRef = size(Cref);
  ABZero = eml_scalar_eg(A0,B0);
  Cout = eml.nullcopy(eml_expand(ABZero,szRef));
  
  return;
end

if (isscalar(A0)&&eml_is_const(isscalar(A0)))||(isscalar(B0)&&eml_is_const(isscalar(B0)))
    
    C = times(A0,B0); % times knows how to handle non-fis/built-ins
    Cout = eml_fimathislocal(C,false);
    
elseif (isfi(A0)&&isfloat(A0))||(isfi(B0)&&isfloat(B0))
      % FiDouble and FiSingle
      % call ML conv directly
    check4constNonFI   = false; % non-FI need not be constant
    check4numericData  = true; % non-FI must be numeric 
    check4sameDatatype = true;  % The datatypes of two inputs must be same
    [Ain,Bin]          = eml_fi_cast_two_inputs(A0,B0,'conv',check4constNonFI,...
                                                  check4numericData,check4sameDatatype);
    [t,f]              = eml_fi_get_numerictype_fimath(A0,B0);
      
    C = conv(Ain, Bin);
    Ctf = eml_cast(C,t,f);
    Cout = eml_fimathislocal(Ctf,false);
    
elseif ((isfi(A0)&&isfixed(A0))||(isfi(B0)&&isfixed(B0)))
        if ~isfi(B0) % fi * non-fi
            [A,B,tA,tB,f] = process_fi_nonfi(A0,B0);
            
        elseif ~isfi(A0) % non-fi * fi
            [B,A,tB,tA,f] = process_fi_nonfi(B0,A0);
            
            
        else % fi * fi
            tA = eml_typeof(A0); tB = eml_typeof(B0);
            % Verify that the datatypes are the same
            % - Scaled-type with floating not allowed
            % - Single with Double not allowed
            [ERR] = eml_const(eml_fi_math_with_same_types(tA,tB));
            eml_assert(isempty(ERR),ERR);
            
            f=eml_checkfimathforbinaryops(A0,B0);
             
            A = A0; B = B0;
        end
        isConstEmptyA = is_const_empty(A);
        isConstEmptyB = is_const_empty(B);
        
        if (isConstEmptyA&&isConstEmptyB)
            
            Cout = process_empty(A, B, f, eml_const(~strcmpi(shape, 'full')));
            
        elseif (isConstEmptyA||isConstEmptyB)
            
            Cout = process_empty(A, B, f, isConstEmptyB);
            
        else
        
            nA = numberofelements(A);
            nB = numberofelements(B);
            nMinAB = min(nA,nB);
            if nargin < 3
                shape = 'full';
            else
                eml_assert(ischar(shape), ...
                    'SHAPE must be ''full'', ''same'', or ''valid''.');
            end
            switch shape
                case 'full'
                    nC = nA + nB - 1;
                    joffset = 0;
                    if nA > nB
                        isOpRow = is_row_vector(A);
                    else
                        isOpRow = is_row_vector(B);
                    end
                case 'same'
                    nC = nA;
                    joffset = ceil((nB-1)/2);
                    isOpRow = (size(A,1) == 1);
                case 'valid'
                    joffset = nB - 1;
                    if nA < joffset
                        nC = 0;
                    else
                        nC = nA - joffset;                
                    end
                    isOpRow = is_row_vector(A);                
                otherwise
                    eml_assert(false, ...
                        'SHAPE must be ''full'', ''same'', or ''valid''.');
            end

            aIsReal = isreal(A); bIsReal = isreal(B);
            maxWL = eml_option('FixedPointWidthLimit');

            [tP,errmsg1] = eml_const(emlGetNTypeForTimes(tA,tB,f,true,true,maxWL));
            if ~isempty(errmsg1)
                eml_assert(0,errmsg1);
            end

            if eml_is_const(size(A))&&eml_is_const(size(B))
                sumLen = nMinAB; 
                isSizeConst = true;
            else
                sumLen = 2; 
                isSizeConst = false;
            end
            [tC,errmsg2] = eml_const(emlGetNTypeForMTimes(tA,tB,f,...
                                aIsReal,bIsReal,sumLen,isSizeConst,maxWL,'CONV'));        
            if ~isempty(errmsg2)
                eml_assert(0,errmsg2);
            end
                        
            
            ABZero = eml_cast(eml_scalar_eg(A,B), tC, f);
            if isOpRow
                C = eml.nullcopy(eml_expand(ABZero,[1, nC]));
            else
                C = eml.nullcopy(eml_expand(ABZero,[nC, 1]));
            end
            % Do the convolution.
            for jC = 1:nC
                j = jC + joffset;
                jp1 = j+1;
                if nB < jp1 % ja1 = max(1,jp1-nB);
                    jA1 = jp1 - nB;
                else
                    jA1 = 1;
                end
                if nA < j % ja2 = min(nA,j);
                    jA2 = nA;
                else
                    jA2 = j;
                end
                if (aIsReal||bIsReal)
                    prodAB = eml_fixpt_times(A(jA1),B(jp1-jA1),tP,tP,f);
                else
                    prodAB = eml_fixpt_times(A(jA1),B(jp1-jA1),tC,tP,f);
                end

                ABZero(1) = prodAB;                
                for k = (jA1+1):jA2
                    if (aIsReal||bIsReal)
                        prodAB = eml_fixpt_times(A(k),B(jp1-k),tP,tP,f);
                    else
                        prodAB = eml_fixpt_times(A(k),B(jp1-k),tC,tP,f);
                    end
                    
                    ABZero(1) = eml_plus(ABZero(1),prodAB,tC,f);
                end
                C(jC) = ABZero(1);
            end
            
            Cout = eml_fimathislocal(C,false);
        end
end

function [u, v, tU, tV, f] = process_fi_nonfi(u0,v0)

    eml.extrinsic('emlGetBestPrecForMxArray');
    eml_assert(eml_is_const(v0), 'In CONV(fi,non-fi), the non-fi must be a constant.');
    eml_assert(isnumeric(v0), 'Data must be numeric.');
    tU = eml_typeof(u0);
    tV = eml_const(emlGetBestPrecForMxArray(v0,tU));
    f = eml_fimath(u0);
    u = u0; v = eml_cast(v0,tV,f);
    
function isConstEmptyU = is_const_empty(u)    

    isEmptyU = isempty(u); 
    isConst = eml_is_const(isEmptyU); 
    isConstEmptyU = (isEmptyU&&isConst);

function C = process_empty(A, B, f, szIsFromA)

    eml.extrinsic('emlGetNTypeForMTimes');
    tC = emlGetNTypeForMTimes(numerictype(A),numerictype(B),...
                    f,isreal(A),isreal(B),1,true,f.maxproductwordlength);
                
    if szIsFromA
        Csa = eml_cast(zeros(size(A)),tC,f);
        C=eml_fimathislocal(Csa,false);        
    else
        Csb = eml_cast(zeros(size(B)),tC,f);
        C=eml_fimathislocal(Csb,false);                
    end
    
function isRowVec = is_row_vector(v)

    isRowVec = (size(v,1) == 1);    

function isConstVec = is_const_vector(v)

    isConstVec = isvector(v)&&eml_is_const(isvector(v));

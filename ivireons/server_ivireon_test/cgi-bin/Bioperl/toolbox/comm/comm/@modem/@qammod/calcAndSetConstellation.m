function calcAndSetConstellation(h, M, phaseOffset)
%CALCANDSETCONSTELLATION Calculate and set signal constellation
% (Constellation property) for MODEM.QAMMOD object H.

%   @modem/@qammod

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:38:15 $

nbits = log2(M);

if nbits == 1
    %trivial case, M = 2;
    constellation = [-1 1];

elseif ( nbits/2 ~= floor(nbits/2) && nbits >3)
    % Cross QAM (except M=8)
    constellation = createCrossConstellation(M);
    
else 
    % Square QAM + M=8
    constellation = createSquareConstellation(M);
    
end

% rotate the constellation by the phase rotation.
constellation = constellation * exp(1i*phaseOffset);

% Constellation should be complex
if isreal(constellation)
    constellation = complex(constellation, 0);
end

h.Constellation = constellation;

%-------------------------------------------------------------------------------
function constellation = createCrossConstellation(M)
%CREATECROSSCONSTELLATION Computes and returns ideal constellation points for 
% Cross QAM Modulation
% This code is copied over from
% $MATLABROOT/toolbox/comm/comm/private/squareqamconst.m

constellation = zeros(1,M);	
nbits = log2(M);

nIbits = (nbits + 1) / 2;
nQbits = (nbits - 1) / 2;
mI = 2^nIbits;
mQ = 2^nQbits;
for i = 0:M-1
    I_data  = fix(i/2^nQbits);
    Q_data = bitand( i, fix(((M-1)/(2^nIbits))));
    cplx_data = (2 * I_data + 1 - mI) + 1i*(-1 * (2 * Q_data + 1 - mQ));
    
    %if(M>8)
    I_mag = abs(floor(real(cplx_data)));
    if(I_mag > 3 * (mI / 4))
        Q_mag = abs(floor(imag(cplx_data)));
        I_sgn = sign(real(cplx_data));
        Q_sgn = sign(imag(cplx_data));
        if(Q_mag > mQ/2)
            cplx_data = I_sgn*(I_mag - mI/2) + 1i*( Q_sgn*(2*mQ - Q_mag));
        else
            cplx_data = I_sgn*(mI - I_mag) + 1i*(Q_sgn*(mQ + Q_mag));
        end 
    end
    %end
    constellation(i+1) =  real(cplx_data) + 1i*imag(cplx_data);
end 

%-------------------------------------------------------------------------------
function constellation = createSquareConstellation(M)
%CREATESQUARECONSTELLATION Computes and returns ideal constellation points for 
% Square QAM Modulation
% This code is copied over from
% $MATLABROOT/toolbox/comm/comm/private/squareqamconst.m

constellation = zeros(1,M);

% Get the QAM points, for 1 quadrant, expand to all 4 quadrants.
Const = idealQAMConst(M);
newConst = [Const; conj(Const); -Const; -conj(Const) ];

for k = 1:M
    % find the elements with the smallest real component
    ind1 = find(real(newConst) == min(real(newConst)));
    % of those, find the element with the largest imaginary component
    tmpArray = -1i*inf * ones(size(newConst));
    tmpArray(ind1) = newConst(ind1);
    ind2 = find(imag(tmpArray) == max(imag(tmpArray)));
    
    constellation(k)= newConst(ind2);
    %get rid of the old point
    newConst(ind2) = [];
end

%-------------------------------------------------------------------------------
function constellation = idealQAMConst(M)
%IDEALQAMCONST Returns a vector of complex numbers corresponding to the ideal
% signalling points for M-ary QAM.  The functions assumes that the I and Q
% QAM signalling points are 1, 3, 5, etc., because the received
% QAM signal is collapsed into the first quadrant.
% This code is copied over from
% $MATLABROOT/toolbox/comm/comm/private/squareqamconst.m

if (M==8)
    constellation = [1+1i; 3+1i];
else 
    % Square QAM
    constellation = zeros((((sqrt(M)-1-1)/2)+1)^2, 1);
    
    cnt = 1;
    for iIndex = 1 : 2 : sqrt(M) - 1
        for qIndex = 1 : 2 : sqrt(M) - 1
            constellation(cnt, 1) = iIndex+1i*qIndex;
            cnt = cnt + 1;
        end
    end
end

%-------------------------------------------------------------------------------
% [EOF]

    
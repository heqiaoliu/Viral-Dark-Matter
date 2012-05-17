function [s,g] = designminordparameq(this,G0,G,GB,Gb,...
    w0,Dw,Dwb,varargin)


%   Author(s): S. Orfanidis and R. Losada 
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:17:28 $

[N,GB,Dw] = determineord(G0,G,GB,Gb,Dw,Dwb,varargin{:});

[s,g] = designparameq(this,2*ceil(N),G0,G,GB,w0,Dw,varargin{:});

%%
function [N,GB,Dw] = determineord(G0,G,GB,Gb,Dw,Dwb,type,Gs)
G0 = 10^(G0/20);
G = 10^(G/20);
GB = 10^(GB/20);
Gb = 10^(Gb/20);
e = sqrt((G^2-GB^2)/(GB^2-G0^2));
eb = sqrt((G^2-Gb^2)/(Gb^2-G0^2));
Fb = eb/e;

WB=tan(Dw/2);
Wb = tan(Dwb/2);
wb=Wb/WB;
switch type
    case 0        
        N=log2(Fb)/log2(wb);
        % Round to next integer
        N = ceil(N);
        e = eb/2^(N*log2(wb));
        GB = sqrt((G^2+e^2*G0^2)/(e^2+1));
    case 1
        u = acos(wb);
        N = acos(Fb)/u;
        % Round to next integer
        N = ceil(N);
        e = eb/cos(N*u);
        GB = sqrt((G^2+e^2*G0^2)/(e^2+1));
    case 2
        u = acos(1/wb);
        N = acos(1/Fb)/u;
        % Round to next integer
        N = ceil(N);
        e = eb/(1/cos(N*u));
        GB = sqrt((G^2+e^2*G0^2)/(e^2+1));
    case 3
        tol = eps;                              % may be changed, e.g., tol=1e-15, or, tol=5 Landen iterations
        Gs = 10^(Gs/20);
        es = sqrt((G^2-Gs^2)/(Gs^2-G0^2));
        k1 = e/es;
        N = 0;
        maxiter = 50; % This value is somewhat arbitrary; it is chosen with the hope that we will never need an elliptic filter of order more than 50.
        err = 1;
        while err > 0 && N < maxiter,
            N = N + 1;
            k  = ellipdeg(N,k1,tol);
            u = acde(Fb,k1,tol)/N;
            cd = cde(u,k,tol);
            err = cd - wb;
        end
        if N == maxiter,
            error(generatemsgid('NotSupported'),'Could not find a suitable order for elliptic design.');
        end 
        % Recompute wb such that err is zero
        wb = cd;
        WB = Wb/wb;
        Dw = 2*atan(WB);
end

GB = 20*log10(GB);

% [EOF]

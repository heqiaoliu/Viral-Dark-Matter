function Y = idltifr(A,B,C,D,U,w)
%IDLTIFR Simulation in the frequency domain.
%   Y = idltifr(A,B,C,D,U,w);
%
%   Calculates the output of a linear system [A,D,C,D] to the
%   frequency domain input signal U(w_k), at frequencies
%   w = [w_k, k=1,...]

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.4.6 $  $Date: 2009/03/09 19:14:32 $

[msg,A,B,C,D] = abcdchk(A,B,C,D);
%Ao=A;Bo=B;Co=C;Do=D;Uo=U;
if ~isempty(msg)
    error(msg)
end
[p,m]=size(D);
% Remove empty inputs
kz = [];
for km=1:m
    if (norm(B(:,km))==0 && norm(D(:,km))==0) || norm(U(:,km))==0
        kz = [kz,km];
    end
end
if ~isempty(kz)
    B(:,kz)=[];
    D(:,kz) = [];
    U(:,kz)=[];
end
[dum,m]=size(B);
%if m==0,keyboard,end
N = length(w);
if m==0
    Y = zeros(N,p);
    return
end


w=w(:);
g1 = mimofr(A,B,C,[],w);
fin = find(isinf(g1));
if ~isempty(fin)
    [l1,l2,l3] = size(g1);
    frnr = floor(min(fin)/l1/l2 +1);
    infreq = w(frnr);
    if frnr ==1
        ctrlMsgUtils.warning('Ident:general:InfiniteFreResp1',num2str(infreq))
    else
        ctrlMsgUtils.warning('Ident:general:InfiniteFreResp2',mat2str(infreq,5))
    end
end

if m>1
    Y = reshape((sum((reshape(shiftdim(g1,1),m,p*N)).*(repmat(U.',1,p)))).',N,p);
else
    Y = reshape(((reshape(shiftdim(g1,1),m,p*N)).*(repmat(U.',1,p))).',N,p);
end
if norm(D)>0
    Y = Y+ U*D.';
end

function [f AA BB CC DD EE IsModelProper] = utComputeRealImagInverseG(G, Type)
% UTCOMPUTEREALIMAGINVERSEG computes: 
% when G is (bi)proper
%   type == 'real': f = 1/(1/G+1/G') = feedback(Model',inv(Model))
%   type == 'imag': f = 1/(1/G-1/G') = feedback(-Model',inv(Model))
% when G is improper
%   type == 'real': f = 1/G+1/G'
%   type == 'imag': f = 1/G-1/G'
%
% test:
%   p=rss(3,1,1);
%   q=1/(1/p+1/p');r=utComputeRealImagInverseG(p,'real');subplot(2,2,1);bode(q,r)
%   q=1/(1/p-1/p');r=utComputeRealImagInverseG(p,'imag');subplot(2,2,2);bode(q,r)
%   invp=1/p;
%   if ~isproper(invp)
%       q=1/invp+1/invp';r=utComputeRealImagInverseG(invp,'real');subplot(2,2,3);bode(q,r)
%       q=1/invp-1/invp';r=utComputeRealImagInverseG(invp,'imag');subplot(2,2,4);bode(q,r)
%   end

% Author(s): Rong Chen 27-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/12/04 22:21:04 $

%% obtain plant in state space form
[IsModelProper,G] = isproper(G);
if IsModelProper
    [A B C D E Ts] = dssdata(G);
    NX = size(A,1);
    if strcmp(Type,'real')
        % f = 1/(1/G+1/G’)
        AA = [A zeros(NX) B;zeros(NX) -A' -C';C B' 2*D];
        BB = [zeros(NX,1);C';-D];
        CC = [C zeros(1,NX) D];
        DD = 0;
        EE = blkdiag(E',E,0);
    else
        % f = 1/(1/G-1/G’) (let B'=-B', D'=-D')
        AA = [A zeros(NX) B;zeros(NX) -A' -C';C -B' 0];
        BB = [zeros(NX,1);C';D];
        CC = [C zeros(1,NX) D];
        DD = 0;
        EE = blkdiag(E',E,0);
    end
else
    [A B C D E Ts] = dssdata(inv(G));
    NX = size(A,1);
    if strcmp(Type,'real')
        % f = 1/G+1/G’
        AA = [A zeros(NX);zeros(NX) -A'];
        BB = [B ; C'];
        CC = [C , -B'];
        DD = D + D';
        EE = blkdiag(E,E');
    else
        % f = 1/G-1/G’ (let C'=-C', D'=-D')
        AA = [A zeros(NX);zeros(NX) -A'];
        BB = [B ; -C'];
        CC = [C , -B'];
        DD = D - D';
        EE = blkdiag(E,E');
    end
end
% Eliminate algebraic variables (Note: f proper by construction)
[dummy f] = isproper(dss(AA,BB,CC,DD,EE,Ts));
[AA,BB,CC,DD,EE] = dssdata(f);
% temporary code for test only
tmp = getPrivateData(f);
if abs(tmp.d)<eps
    tmp.d = 0;
    f = setPrivateData(f,tmp);
end
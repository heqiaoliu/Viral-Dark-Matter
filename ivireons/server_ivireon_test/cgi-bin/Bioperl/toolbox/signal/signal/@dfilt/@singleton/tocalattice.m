function Hd2 = tocalattice(Hd);
%TOCALATTICE  Convert to coupled allpass lattice.
%   Hd2 = TOCALATTICE(Hd) converts discrete-time filter Hd to coupled allpass
%   lattice filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2007/12/14 15:09:48 $ 

[b,a] = tf(Hd);
if signalpolyutils('isfir',b,a),
    % FIR case
    if length(find(b~=0))>1,
        error(generatemsgid('DFILTErr'),'The FIR filter must be allpass.');
    elseif length(find(b~=0))==1,
        % Pad a with zeros
        a(2:length(b)) = 0;
    end
end
if length(b)~=length(a),
    error(generatemsgid('InvalidDimensions'),'The number of poles and zeros must be equal.');
end
[k1,k2,beta] = tf2cl(b,a);
Hd2 = dfilt.calattice(k1,k2,beta);

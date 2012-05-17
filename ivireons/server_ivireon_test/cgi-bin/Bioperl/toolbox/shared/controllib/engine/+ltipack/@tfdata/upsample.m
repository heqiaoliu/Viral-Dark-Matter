function D = upsample(D,L)
%Upsample a discrete TF model by a factor of L.

%   Author: Murad Abu-Khalaf, April 30, 2008
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:33:09 $

% Compute discrete delays for resampled system
D.Delay.Input = D.Delay.Input * L;
D.Delay.Output = D.Delay.Output * L;
D.Delay.IO = D.Delay.IO * L;

% Update the new sampling time.
D.Ts = D.Ts/L;

% Loop over I/O pairs
for ct=1:numel(D.num)
    % Resample
    num_up = kron(D.num{ct},[zeros(1,L-1) 1]);
    den_up = kron(D.den{ct},[zeros(1,L-1) 1]);    
    % Update corresponding I/O pair in resampled TF
    D.num{ct} = num_up(L:end);
    D.den{ct} = den_up(L:end);
end

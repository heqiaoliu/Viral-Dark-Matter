function y = filter(cf, x, z)
% Channel filtering.
% The current implementation is for multipath fading channels.
%
%    cf - Channel filter object
%    x  - Input signal
%    z  - Evolution of path gains (optional)
%    y  - Output signal

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/01/25 21:28:22 $

% Starting state.  Use PrivateData for speed.
u = cf.PrivateData.State.';

[Ns Nt] = size(x);                      % Number of samples, number of Tx antennas
L = length(cf.PrivateData.PathDelays);  % Number of multipaths
Nr = cf.PrivateData.NumRxAntennas;      % Number of Rx antennas
NL = Nt * Nr;                           % Number of links (Nt x Nr)

% If z not specified, use current tap gains of channel filter.
% Perform channel filtering using MATLAB code.
if nargin==2

    g = cf.TapGains.';
    Lt = size(cf.AlphaMatrix,2);
    
    % Frequency-flat fading
    if Lt==1
            
        y = zeros(NL, Ns);
        for it = 1:Nt
            idx = (it-1)*Nr + (1:Nr);           
            y(idx,:) = diag(g(idx,:)) * repmat(x(:,it).',[Nr 1]);
        end
        y = y.';

    else    % Frequency-selective fading        
        
        y = zeros(Ns, NL);
        for n = 1:Ns
            for it = 1:Nt
                u( (it-1)*Lt + (2:Lt) ) = u( (it-1)*Lt + (1:Lt-1) );
                u( (it-1)*Lt + 1 ) = x(n,it);
                for ir = 1:Nr
                    idxy = (it-1)*Nr + ir;
                    idxg = (idxy-1)*Lt + (1:Lt);
                    idxu = (it-1)*Lt + (1:Lt);
                    y(n,idxy) = g(idxg,1).' * u(idxu);
                end
            end
        end
            
    end

else
    
    % Rearrange matrix for channel filtering.
    zc = zeros(NL*L, Ns);
    for it = 1:Nt
        for ir = 1:Nr 
            for il = 1:L 
                idxc = (it-1)*(L*Nr) + (ir-1)*L + il;
                idx = (il-1)*NL + (it-1)*Nr + ir;
                zc(idxc,:) = z(idx,:);
            end
        end
    end
        
%%
% MATLAB code version corresponding to the Mex function call.
% Uncomment this section and comment the following one to use the MATLAB code version 
%    % Calculate the g.
%    Lt = size(cf.AlphaMatrix,2);
%    g = zeros(Lt*NL,Ns);
%    for it = 1:Nt
%        for ir = 1:Nr
%            idx = (it-1)*Nr + ir - 1;
%            idxg = idx*Lt + (1:Lt);
%            idxz = idx*L + (1:L);
%            g(idxg,:) = cf.AlphaMatrix.' * zc(idxz,:);
%        end
%    end
%    cf.TapGains = g(:, Ns).';
%
%    % Frequency-flat fading
%    if Lt==1
%
%        y = zeros(NL,Ns);
%        for it = 1:Nt
%            idx = (it-1)*Nr + (1:Nr);
%            y(idx,:) = g(idx,:) .* repmat(x(:,it).',[Nr 1]); 
%        end  
%        y = y.';
%        
%    % Frequency-selective fading
%    else
%
%        U = zeros(Nt*Lt,Ns);
%        for it = 1:Nt
%            idxU = (it-1)*Lt + (1:Lt); 
%            idxu = (it-1)*Lt + (1:(Lt-1));
%            U(idxU,:) = toeplitz([x(1,it); u(idxu)], x(:,it));
%        end    
%        u = U(:, end);
%        
%        y = zeros(NL,Ns);
%        for it = 1:Nt
%            for ir = 1:Nr
%                idxy = (it-1)*Nr + ir;
%                idxg = (idxy-1)*Lt + (1:Lt);
%                idxU = (it-1)*Lt + (1:Lt);
%                y(idxy,:) = sum( g(idxg,:) .* U(idxU,:) , 1); 
%            end
%        end    
%        y = y.';
%        
%    end
        
%%
    if isreal(x)
        x = complex(x);
    end
    y = mimochanfilt(x, zc.', cf.AlphaMatrix, u);
%%    

end

% End state.  Use PrivateData for speed.
cf.PrivateData.State = u.';

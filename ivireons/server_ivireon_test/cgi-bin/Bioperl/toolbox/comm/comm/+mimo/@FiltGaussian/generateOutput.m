function y = generateOutput(s, NS)
%GENERATEOUTPUT  Generate output from filtered Gaussian source object.
%   Y = GENERATEOUTPUT(S, NS) generates M fading process outputs, where M
%   is (number of paths) X (number of links) and NS
%   is the length of each random process.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/01/25 21:28:23 $

% Extract private data (used for speed, instead of individual properties).
sData = s.PrivateData;

% Number of paths
NP = sData.NumChannels;

% Number of links
NL = sData.NumLinks;

% Number of fading processes and length of state vectors.
[M Ls] = size(sData.State); %#ok<NASGU>

% If no outputs required, return empty matrix (with correct number of
% rows).
if NS==0, y=zeros(M, 0); return; end

%%
% MATLAB code version corresponding to the Mex function call.
% Uncomment this section and comment the following one to use the MATLAB code version 
%    
% % Gaussian noise generation
% 
% Create a local random number stream using either the seed or
% % the full state stored in source object.
% if isscalar(sData.WGNState)
%     stream = RandStream('shr3cong','seed',sData.WGNState);
% else
%     stream = RandStream('shr3cong');
%     stream.State = sData.WGNState;
% end
% 
% % Generate noise vector with prepended state.
% % Generated as 2*M x L to handle real/imag parts in correct order.
% % This order can be important when resetting state.
% w2 = 1/sqrt(2) * randn(stream, 2*M, NS);
% wgnoise = [sData.State (w2(1:M,:) + j*w2(M+1:end,:))];
% 
% % Save normal random number generator state to source object
% % and restore state of MATLAB random normal number generator.
% sData.WGNState = stream.State;
% 
% % Doppler filtering
%     
% % Impulse response of filter.
% h = sData.ImpulseResponse;
% [Nh, Lh] = size(h);
% 
% y = zeros(M, NS);
% % One impulse response vector for all channels
% if Nh == 1
%     for m = 1:M
%         yrow = conv(h, wgnoise(m, :));  % Filter noise.
%         y(m, :) = yrow(Lh:end-Lh+1);    % Trim waveform.
%     end
% % Matrix of impulse responses (one per channel)   
% else
%     m = 0;
%     n = 0;
%     for ic = 1:NP
%         n = n+1;
%         for il = 1:NL
%             m = m+1;
%             yrow = conv(h(n,:), wgnoise(m, :));
%             y(m, :) = yrow(Lh:end-Lh+1);
%         end
%     end    
% end    
% 
% % Spatial correlation (if applicable)
% RH = sData.SQRTCorrelationMatrix;
% ndimsRH = ndims(RH);
% 
% if ndimsRH==1
%     % No need to do multiplication (SQRTCorrelationMatrix = 1)
% elseif ( ndimsRH==2 && isequal(RH, eye(length(RH))) )  
%     % No need to do multiplication (SQRTCorrelationMatrix = eye matrix)
% else
%     for i = 1:NP
%         idx = 1+(i-1)*NL : i*NL;
%         y(idx,:) = RH(:,idx) * y(idx,:);
%     end
% end
% 
% % Update state and last outputs.
% sData.State = wgnoise(:, end-Ls+1:end);
% 
% % Store last *two* outputs for each channel.
% % Needed for interpolation by parent objects.
% if NS==1
%     sData.LastOutputs = [sData.LastOutputs(:, end) y(:, 1)];
% else
%     sData.LastOutputs = y(:, end-[1 0]);
% end

%%
% Force a copy of sData.
% Changing WGNState makes sure this happens.
sData.WGNState = sData.WGNState + 0;

SQRTisEye = isequal(sData.SQRTCorrelationMatrix, eye(length(sData.SQRTCorrelationMatrix)));

if isreal(sData.SQRTCorrelationMatrix)
    SQRTCorrelationMatrixComplex = complex(sData.SQRTCorrelationMatrix);
else
    SQRTCorrelationMatrixComplex = sData.SQRTCorrelationMatrix;
end

y = mimofggen(...
    NS, ...
    NP, ...
    NL, ...
    sData.ImpulseResponse, ...
    sData.State, ...
    sData.LastOutputs, ...
    sData.WGNState, ...
    SQRTCorrelationMatrixComplex, ...
    SQRTisEye, ...
    double(legacychannelsim));
y = y.';
    
%%    
% Store private data.
s.PrivateData = sData;

if sData.UseStats
    storeOutput(s, y);
end    

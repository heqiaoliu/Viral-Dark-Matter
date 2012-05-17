function [y, yd] = filter(f, s, Nout)
% Interpolation filtering.
%
% Inputs:
%   f  - Interpolating filter object.
%   s  - Input source object.
%   y  - Output signal.
%   yd - Before interpolation (and delayed).

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:55:05 $

%%
% M-code version corresponding to the Mex function call in @rayleighfading
% /generateBlock.m. Uncomment this file to use the M-code version. 
%
% % If first call, load up filter to initialize interpolation.
% if f.NumSamplesProcessed==0
%    x = generateOutput(s, f.PrivateData.SubfilterLength); 
%    reset(f, x);
% end
% 
% % Linear interpolation factor.
% KI = f.PrivateData.LinearInterpFactor;
% 
% if KI==1
%     % Polyphase filtering only; no linear interpolation.
%     [y, yd] = polyphaseFilter(f, s, Nout);
% 
% else
%     % Hybrid of polyphase filtering and linear interpolation.
% 
%     % Linear interpolation indices.
%     startIdx = f.PrivateData.LinearInterpIndex;
%     endIdx = startIdx + Nout - 1;
% 
%     % Number of samples required for linear interpolation.  Special cases:
%     % startIdx==1 and Nout==1 ==> numSamples = 1 (no interpolation)
%     % startIdx==1 and Nout<=KI+1 OR
%     % startIdx==2 and Nout<=KI ==> numSamples = 2 (2-pt interpolation)
%     numSamples = ceil((endIdx-1) / KI) + 1;
% 
%     % Determine *previous* polyphase filter outputs.
%     % If startIdx of linear interpolation is 1 or 2,
%     % use only last filter output.
%     % Otherwise, use last *two* outputs.
%     numPrevOutputs = (startIdx>2)+1;
%     idx = (numPrevOutputs-1):-1:0;
%     prevOutputs = f.PrivateData.LastFilterOutputs(:, end-idx);
% 
%     % Generate *new* polyphase filter outputs.
%     numNewOutputs = numSamples - numPrevOutputs;
% 
%     [newOutputs, yd] = polyphaseFilter(f, s, numNewOutputs);
% 
%     % Samples for linear interpolation.
%     samples = [prevOutputs newOutputs];
% 
%     % Linear interpolation of polyphase filter outputs.
%     M = f.PrivateData.NumChannels * f.PrivateData.NumLinks;
%     y = zeros(M, Nout);
%     for m = 1:M
%         y(m, :) = linearInterpolation(samples(m, :), KI, startIdx:endIdx);
%     end
% 
%     % Starting interpolation index for the next block.
%     f.PrivateData.LinearInterpIndex = rem(endIdx, KI) + 1;
% 
% end
% 
% % Increment number of source samples processed.
% numSourceSamples = size(yd, 2);
% f.NumSamplesProcessed = f.NumSamplesProcessed + numSourceSamples;
% 
% %--------------------------------------------------------------------------
% function [y, x, N] = polyphaseFilter(f, s, NS)
% % Output samples from polyphase filter.
% % f: Interpolating filter object.
% % s: Source object.
% % NS: Requested number of output samples to generate (in y).
% % y: Output samples matrix (f.NumChannels x NS).
% % x: Source outputs (f.NumChannels x N).
% % N: Number of source samples processed.
% 
% M = f.PrivateData.NumChannels * f.PrivateData.NumLinks;
% % Initialize output vectors.
% y = zeros(M, NS); 
% x = zeros(M, 0);
% 
% % Return if no output samples requested; no source samples required.
% if NS==0
%     N=0; 
%     return
% end
% 
% % Polyphase filter interpolation factor.
% R = f.PrivateData.PolyphaseInterpFactor;
% 
% % Increment polyphase filter phase by 1.
% % The additional -1 and +1 are because phase is 1-based, 
% % but mod is 0-based.
% startPhase = mod(f.PrivateData.FilterPhase+1 - 1, R) + 1; 
% 
% if R==1
% 
%     % No polyphase interpolation.
% 
%     N = NS; % Number of source samples equals number of output samples.
%     x = generateOutput(s, N);  % Generate source samples.
%     y = x;  % Output samples are exactly equal to source samples.
%     u = x(:, end).'; % State matrix (see below)
%     
%     % Note: In this case, the state matrix is not used, but is included for
%     % completeness. 
% 
% else
% 
%     L = f.PrivateData.SubfilterLength;
%     g = f.PrivateData.FilterBank;
%     u = f.PrivateData.FilterInputState.';
% 
%     % m0 is the number of samples to output *without* generating new source
%     % samples.  This is necessary when the starting phase is not equal to
%     % 1.
%     m0 = mod(R - (startPhase - 1), R);
% 
%     if m0>NS, m0 = NS; end
% 
%     % Flush polyphase filter if needed.
%     if m0>0
%         y(:, 1:m0) = (g((1:m0)+startPhase-1, :)*u).';
%     end
% 
%     % Required number of source samples.
%     N = ceil((NS - m0)/R);
%     
%     % Compute outputs if new source samples needed.
%     if N>0
% 
%         x = generateOutput(s, N);
%                         
%         % Indices for output vector.
%         m1 = m0 + (0:N-1)*R + 1;
%         m2 = m1 + R - 1;
%         Lm = R(ones(1,N)); % Length of subvector.
%         if m2(end)>NS
%             m2(end) = NS;
%             Lm(end) = m2(end) - m1(end) + 1;
%         end
%                 
%         % Indices for state vector.
%         i1 = 1:L-1;
%         i2 = i1+1;
% 
%         % Compute outputs and update state matrix.
%         for n = 1:N
%             u(i2, :) = u(i1, :);
%             u(1, :) = x(:, n).';
%             y(:,m1(n):m2(n)) = (g(1:Lm(n),:)*u).';
%         end
%         
%     end
% 
% end
% 
% % Store input state matrix.
% f.PrivateData.FilterInputState = u.';
% 
% % Update polyphase filter phase.
% % The additional -1 and +1 are because phase is 1-based,
% % but mod is 0-based.
% f.PrivateData.FilterPhase = mod(startPhase+(NS-1) - 1, R) + 1;
% 
% % Store last *two* outputs for each path. 
% % Needed for linear interpolation.
% if NS==1
%     f.PrivateData.LastFilterOutputs = [f.PrivateData.LastFilterOutputs(:, end) y];
% else
%     f.PrivateData.LastFilterOutputs = y(:, end-[1 0]);
% end
% 
% %--------------------------------------------------------------------------
% function z = linearInterpolation(y, N, i)
% 
% % for N>1
% D = [diff(y) 0]; % Last value not important, but needed for indexing.
% b = (i-1)/N;
% k = floor(b);
% n = k+1; % Index into y, based on index into z.
% z =  y(n) + (b-k).*D(n);

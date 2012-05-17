function decoded = decode(obj, LLR)
%DECODE  Decode an LDPC code.
%   DECODED = DECODE(L, LLR) decodes an LDPC code using the message-passing
%   algorithm.
%
%   L       - An LDPC decoder object.
%   LLR     - A 1-by-L.BlockLength double vector. Bitwise log-likelihood
%             ratios for the transmitted bits conditional on the received
%             signal. A bit is more likely a '1' if the corresponding
%             log-likelihood ratio is negative.
%   DECODED - Decoder output. If L.DecisionType is 'Hard decision', DECODED
%             is the decoded bits. If L.DecisionType is 'Soft decision',
%             DECODED is the log-likelihood ratios for the decoded bits. If
%             L.OutputFormat is 'Information part', DECODED is a
%             1-by-L.NumInfoBits vector. If L.OutputFormat is 'Whole
%             codeword', DECODED is a 1-by-L.BlockLength vector.
%
%   This function uses L.DecisionType, L.OutputFormat, L.NumIterations,
%   L.DoParityChecks, and updates L.FinalParityChecks,
%   L.ActualNumIterations.
%
%   Example:
%
%     enc = fec.ldpcenc;  % Construct a default LDPC encoder object
%     dec = fec.ldpcdec;  % Construct a companion LDPC decoder object
%     dec.DecisionType = 'Hard decision';     % Set decision type
%     dec.OutputFormat = 'Information part';  % Set output format
%     dec.NumIterations = 50;                 % Set number of iterations
%     dec.DoParityChecks = 'Yes';  % Stop if all parity-checks are satisfied
%     msg = randi([0 1],1,enc.NumInfoBits);   % Generate a random binary message
%     codeword = encode(enc,msg);          % Encode the message
%     % Construct a BPSK modulator object
%     modObj = modem.pskmod('M',2,'InputType','Bit');
%     % Modulate the signal (map bit 0 to 1 + 0i, bit 1 to -1 + 0i)
%     modulatedsig = modulate(modObj, codeword);
%     % Noise parameters
%     SNRdB = 1;
%     sigma = sqrt(10^(-SNRdB/10));
%     % Transmit signal through AWGN channel
%     receivedsig = awgn(modulatedsig, SNRdB, 0); % Signal power = 0 dBW
%     % Visualize received signal
%     scatterplot(receivedsig)
%     % Construct a BPSK demodulator object to compute log-likelihood ratios
%     demodObj = modem.pskdemod(modObj,'DecisionType','LLR', ...
%                'NoiseVariance',sigma^2);
%     % Compute log-likelihood ratios (AWGN channel)
%     llr = demodulate(demodObj, receivedsig);
%     % Decode received signal
%     decodedmsg = decode(dec, llr);
%     % Actual number of iterations executed
%     disp(['Number of iterations executed = ' ...
%          num2str(dec.ActualNumIterations)]);
%     % Number of parity-checks violated
%     disp(['Number of parity-checks violated = ' ...
%          num2str(sum(dec.FinalParityChecks))]);
%     % Compare with original message
%     disp(['Number of bits incorrectly decoded = ' ...
%          num2str(nnz(decodedmsg-msg))]);
%
%   See also FEC.LDPCDEC, FEC.LDPCENC, FEC.LDPCENC/ENCODE, MODEM/DEMODULATE.

%   @fec/@ldpcdec

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/12/05 01:58:28 $

validateattributes(LLR, {'double'}, {'size', [1 obj.BlockLength]}, ...
  'fec.ldpcdec.decode', 'LLR');

dectype        = strcmp(obj.DecisionType, 'Hard decision');
doeachcheck    = strcmp(obj.DoParityChecks, 'Yes');
dofinalcheck   = 1; % hard-coded to update obj.FinalParityChecks

%% C-implementation of iterative decoder

[decoded, ~, ~, ~, obj.ActualNumIterations, obj.FinalParityChecks] = ...
ldpcdecode(LLR, obj.NumIterations, obj.BlockLength, obj.NumParityBits, ...
           length(obj.rlist), length(obj.dlist)/2, obj.dlist, obj.rlist, ...
           int8(dectype), int8(doeachcheck), int8(dofinalcheck));

%% Format output
if strcmp(obj.OutputFormat, 'Information part')
    decoded = decoded(1:obj.NumInfoBits);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% M-implementation of iterative decoder
% 
% function decoded = decode_M(obj, LLR)
% %   Copyright 2006 The MathWorks, Inc.
% 
% % This implementation is only for illustrating the decoding algorithm.
% % There is an extremely small probability that division by zero may occur.
% % The C-implementation does not have this issue.
% 
% if size(LLR, 1) ~= 1 || size(LLR, 2) ~= obj.BlockLength
%     error('comm:ldpcdec:InvalidInputDimensions', ...
%           'LLR must be a 1-by-BlockLength vector.');
% end
% 
% dectype        = strcmp(obj.DecisionType, 'Hard decision');
% doeachcheck    = strcmp(obj.DoParityChecks, 'Yes');
% 
% N_Iter = obj.NumIterations;
% NGrp = length(obj.dlist)/2;
% 
% %% M-implementation of iterative decoder
% 
% [i2, j2] = find(obj.ParityCheckMatrix);
% grplist = reshape(obj.dlist, 2, []);
% Lq = LLR(j2);
% 
% % Key variables inside for-loop:
% % Lq, Lr, decoded
% 
% for iteration = 1:N_Iter
%     Lq = tanh(Lq/2);
% 
%     prodLq = ones(1,obj.NumParityBits);
%     for nn = 1:length(i2)
%         prodLq(i2(nn)) = prodLq(i2(nn)) * Lq(nn);
%     end
% 
%     Lr = 2*atanh(prodLq(i2)./Lq);
%     Lr(Lr == Inf) = 2*19.07; % 19.07 is the smallest x (up to 2 decimal places) s.t. tanh(x) == 1
%     Lr(Lr == -Inf) = -2*19.07;
% 
%     decoded = LLR;
%     
%     offset1 = 0;
%     offset2 = 0;
%     for g = 1:NGrp
%         decoded(offset1+(1:grplist(1,g))) = decoded(offset1+(1:grplist(1,g))) + ...
%             sum(reshape(Lr(offset2+(1:grplist(1,g)*grplist(2,g))), grplist(2,g), grplist(1,g)), 1);
%         offset1 = offset1 + grplist(1,g);
%         offset2 = offset2 + grplist(1,g)*grplist(2,g);
%     end
%     
%     Lq = decoded(j2) - Lr;
%     
%     if doeachcheck == 1
%         harddecision = double(decoded < 0);
%         obj.FinalParityChecks = mod(obj.ParityCheckMatrix * harddecision', 2);
%         if isempty(find(obj.FinalParityChecks,1))
%             break;
%         end
%     end
% end
% 
% %% Format output
% 
% obj.ActualNumIterations = iteration;
% 
% if doeachcheck ~= 1
%     harddecision = double(decoded < 0);
%     obj.FinalParityChecks = mod(obj.ParityCheckMatrix * harddecision', 2);
% end
% 
% if dectype == 1
%     decoded = harddecision;
% end
% 
% if strcmp(obj.OutputFormat, 'Information part')
%     decoded = decoded(1:obj.NumInfoBits);
% end

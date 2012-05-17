function type = algType(h,N,K,short,puncs)
% ALGTYPE Set the Type string for the Algebraic encoder
%
%   Inputs:
%     h: Encoder/Decoder object
%     N: Code length
%     K: Message Length
%     Short: Shortening Length
%     Puncs: Puncture Vector

% @fec\@bchdec

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:22:05 $

numPuncs = sum(~puncs);
actN = N - short - numPuncs;
actK = K - short;

if ~(h.Nset && h.Kset)
    type = '';
    return
end


%Basic string
if(actN == N  && actK == K)
    type = ['(', num2str(actN), ',' ,num2str(actK), ') BCH Decoder'];
    return
end

if(short > 0 && numPuncs == 0)
    type = ['Shortened (', num2str(actN), ',' ,num2str(actK), ') BCH Decoder'];
elseif (short == 0 && numPuncs > 0)
    type = ['Punctured (', num2str(actN), ',' ,num2str(actK), ') BCH Decoder'];
else
    type = ['Shortened, Punctured (', num2str(actN), ',' ,num2str(actK), ') BCH Decoder'];
end
function nfft = set_nfft(this, nfft) %#ok
%SET_NFFT   PreSet function for the 'nfft' property.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:14:55 $

% Welch uses segment length instead of input length.
% nextpow2 = max(256,nextpow2(inputlength))
% auto = max(256,inputlength)

validStrs = {'Auto','Nextpow2'};
msgID = generatemsgid('invalidNFFTValue');
msgStr = {'%s\n%s ''%s'' or ''%s''.\n',...
    'Invalid NFFT value specified.  NFFT must be a positive integer or one ',...
    'of the two valid strings:',validStrs{:}};

if isnumeric(nfft),
    if nfft<=0,
        error(msgID,msgStr{:});
    end

else
    idx = [];
    for k=1:length(validStrs),
        if regexp(lower(validStrs{k}),['^',lower(nfft)],'once');
            idx=k;
        end
    end
    if isempty(idx),
        error(msgID,msgStr{:});
    else
        % Use full string with correct capitalization.
        nfft = validStrs{idx};
    end
end

% [EOF]

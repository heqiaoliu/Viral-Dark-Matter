function freqpoints = set_freqpoints(this, freqpoints) %#ok
%SET_freqpoints   PreSet function for the 'freqpoints' property.

%   Author(s): W. Syed
%   Copyright 1988-2006 The MathWorks, Inc.

% FreqPoints takes an enum type of {'All', 'User Defined'}
% A choice of 'All' dynamicall creates 'nfft' field
% A choice of 'User Defined' sets up 'FrequencyVector' field

validStrs = {'All','User Defined'};
msgID = generatemsgid('invalidFreqPointsValue');
msgStr = {'%s\n%s ''%s'' or ''%s''.\n',...
    'Invalid FreqPoints value specified.  FreqPoints must be one ',...
    'of the two valid strings:',validStrs{:}};

if isnumeric(freqpoints),
    error(msgID,msgStr{:});
else
    idx = [];
    for k=1:length(validStrs),
        if regexp(lower(validStrs{k}),['^',lower(freqpoints)],'once');
            idx=k;
        end
    end
    if isempty(idx),
        error(msgID,msgStr{:});
    else
        % Use full string with correct capitalization.
        if (idx==1)
            rmdynprop(this,'FrequencyVector');
            if ~isprop(this,'NFFT'),
                adddynprop(this,'NFFT','mxArray',@set_nfft); 
            end
            this.NFFT = 'Nextpow2';
        elseif (idx==2)
            rmdynprop(this,'NFFT');
            if ~isprop(this,'FrequencyVector'),
                adddynprop(this,'FrequencyVector','mxArray', @set_frequencyvector);
            end
            this.FrequencyVector = 'Auto';
        else
            error(msgID,msgStr{:});
        end
    end
end

% [EOF]

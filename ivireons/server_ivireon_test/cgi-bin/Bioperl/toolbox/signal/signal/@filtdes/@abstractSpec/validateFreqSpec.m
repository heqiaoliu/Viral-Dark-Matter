function varargout = validateFreqSpec(~, d, varargin)
%VALIDATEFREQSPEC Validate the freqspec

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:10:17 $

success   = true;
exception = MException.empty;

% Calculate the nyquest frequency
if d.isnormalized
    nyq = 1;
else
    nyq = d.Fs/2;
end

% Go through all the properties and make sure they are all below the
% nyquist frequency.
for indx = 1:numel(varargin)
    try
        value = d.(varargin{indx});
    catch ME
        switch ME.identifier
            case {'MATLAB:noSuchMethodOrField', 'MATLAB:class:GetDenied'}
                continue;
            otherwise
                rethrow(ME);
        end
    end
    if value > nyq
        success = false;
        exception = MException('signal:fdatool:InvalidFreqSpec', ...
            fdatoolmessage('InvalidFreqSpec', varargin{indx}, nyq));
    end
end

if nargout
    varargout = {success, exception};
elseif ~success
    throw(exception);
end

% [EOF]

function fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin)
%FSCONSTRUCTOR   Base constructor for all specs with Fs.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:13:56 $


error(nargchk(0,nargsnoFs+1,length(varargin),'struct'));


freqargs = [varargin{fstart:min(length(varargin),fstop)}];

if length(varargin) > nargsnoFs
    % Fs specified
    Fs = varargin{nargsnoFs+1};
    if any(freqargs > Fs/2),
        error(generatemsgid('invalidSpec'), 'Band-edge frequencies cannot exceed half the sampling frequency.');
    end
else
    % Fs not specified
    if ~isempty(freqargs) && any(freqargs > 1),
        error(generatemsgid('invalidSpec'), 'Band-edge frequencies cannot exceed one.');
    end
end

this.ResponseType = respstr;

this.setspecs(varargin{:});

% [EOF]

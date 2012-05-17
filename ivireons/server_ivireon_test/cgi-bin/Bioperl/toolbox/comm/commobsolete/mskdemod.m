function [z, varargout] = mskdemod(y, nSamp, varargin)
%MSKDEMOD Minimum shift keying demodulation.
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use MODEM.MSKDEMOD object instead.
%
%
%   Z = MSKDEMOD(Y,NSAMP) demodulates the complex envelope Y of a signal using
%   the minimum shift keying method.  NSAMP denotes the number of samples per
%   symbol and must be a positive integer.  For two dimensional signals, the
%   function treats each column of data as one channel.
%
%   Z = MSKDEMOD(Y,NSAMP,DATAENC) specifies the data encoding method for MSK.
%   DATAENC can be either 'diff', specifying differentially encoded MSK, or
%   'nondiff', specifying nondifferentially encoded MSK.  The default is 'diff'.
%   The 'diff' and 'nondiff' methods are equivalent to conventional and precoded
%   MSK, respectively.  
%
%   Z = MSKDEMOD(Y,NSAMP,DATAENC,INI_PHASE) specifies the initial phase of the
%   demodulator.  INI_PHASE is a row vector whose length is equal to the number
%   of channels in Y, and has default values of 0.  Values in INI_PHASE must be
%   integer multiples of pi/2. To avoid overriding the default value of DATAENC,
%   set DATAENC=[].
%
%   Z = MSKDEMOD(Y,NSAMP,DATAENC,INI_PHASE,INI_STATE) specifies the initial
%   state of the demodulator.  INI_STATE is complex, with length NSAMP, and
%   contains the last half symbol of the previously received signal.  If Y is
%   two dimensional, then INI_STATE must have NSAMP rows, and the same number of
%   columns as Y.
%
%   [Z,PHASEOUT] = MSKDEMOD(...) returns the final phase of Y for use in
%   demodulating a future signal. PHASEOUT has the same dimensions as INI_PHASE
%   above, and takes on the values 0, pi/2, pi, and 3*pi/2.
%
%   [Z,PHASEOUT,STATEOUT] = MSKDEMOD(...) returns the final NSAMP values of Y
%   for use in demodulating a future signal.  The format of STATEOUT is the same
%   as that of INI_STATE above.
%
%   See also MSKSKMOD, FSKMOD, FSKDEMOD, MODEM.MSKDEMOD, MODEM, MODEM/TYPES.

%   Reference:  
%   [1] S. Pasupathy, "MSK: A Spectrally Efficient Modulation", IEEE
%   Communications Magazine, July 1979.
%   [2] M.K. Simon, S.M. Hinedi, and H.C. Lindsey, Digital Communication
%   Techniques - Signal Design and Detection, New Jersey: Prentice Hall, 1995

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/08 15:53:55 $


% Error checks ----------------------------------------------------------------

% Check the number of input arguments
error(nargchk(2, 5, nargin, 'struct'));

% Check Y
if (~isnumeric(y) || isreal(y))
    error('comm:mskdemod:yComplex', 'Elements of input Y must be complex.');
end

% Check that NSAMP is a positive integer
if(~isnumeric(nSamp) || ~isscalar(nSamp) || ...
        (ceil(nSamp) ~= nSamp) || (nSamp <= 0))
    error('comm:mskdemod:nSampPos', 'NSAMP must be a positive integer.');
end

% Check that the length of Y is an integral multiple of NSAMP
if min(size(y)) > 1   % if multichannel
    yLength = size(y, 1);
else
    yLength = length(y);
end
if yLength/nSamp ~= round(yLength/nSamp)
    error('comm:mskdemod:yLength', ...
        'The number of samples in Y must be an integral multiple of NSAMP.');
end

% Check DATAENC
if nargin >= 3
    dataEnc = varargin{1};
    if isempty(dataEnc)
        dataEnc = 'diff';
    else
        valDataEnc = {'diff' 'nondiff'};
        if ~ismember(dataEnc, valDataEnc)
            error('comm:mskdemod:invDataEnc', ...
                'DATAENC must be either ''diff'' or ''nondiff''.');
        end
    end
else
    dataEnc = 'diff';
end

% Check INI_PHASE. In doing so, assure that Y, if one dimensional, has the
% correct orientation.
nRowsInit = size(y, 1);
if nRowsInit == 1
    y = y(:);
end
nChan = size(y, 2);     % # of channels
sigLen = size(y, 1);    % signal length in samples
nBits = sigLen / nSamp;  % signal length in bits

if nargin >= 4
    ini_phase = varargin{2};
    if isempty(ini_phase)
        ini_phase = zeros(1, nChan);
    else
        valIniPhase = [0 pi/2 pi 3*pi/2];
        if (~isnumeric(ini_phase) || ~isvector(ini_phase) || ...
                ~isreal(ini_phase) || size(ini_phase,2)~=nChan)
            error('comm:mskdemod:invIniPhase', ...
                ['INI_PHASE must be a real row vector with values equal to ', ...
                'integer multiples of pi/2 for each channel.']);
        end
        for iChan = 1 : nChan
            if (~any(any(ini_phase(iChan) == valIniPhase)))
                error('comm:mskdemod:invIniPhase', ...
                    ['INI_PHASE must be a real row vector with values equal ', ...
                    'to integer multiples of pi/2 for each channel.']);
            end
        end
    end
else
    ini_phase = zeros(1, nChan);
end
ini_phase = repmat(ini_phase, sigLen+nSamp, 1);

% Check INI_STATE
if nargin == 5
    ini_state = varargin{3};
    if isempty(ini_state)
        ini_state = repmat(complex(zeros(nSamp,1)), 1, nChan);
    else
        nRowsState = size(ini_state, 1);
        if nRowsState == 1
            ini_state = ini_state(:);
        end
        [nRowsState, nColState] = size(ini_state);
        if (~isnumeric(ini_state) || isreal(ini_state) || ...
                nRowsState ~= nSamp || nColState ~= nChan)
            error('comm:mskdemod:invIniState', ...
                ['INI_STATE must be complex, with NSAMP samples per channel,'...
                ' and with the same number of columns as channels in Y.']);
        end
    end
else
    ini_state = repmat(complex(zeros(nSamp,1)), 1, nChan);
end

% End of error checking -------------------------------------------------------

% Return STATEOUT if specified
if nargout == 3
    varargout{2} = y(end-nSamp+1:end,:);
end

% Prepend the state.  For nondifferentially encoded signals, prepend the last
% nSamp samples of the current signal.
if strcmpi(dataEnc, 'diff')
    y = [ini_state; y];
else
    y = [y(end-nSamp+1:end,:); y];
end

% Remove the initial phase
y = y .* exp(-j*ini_phase);

% Perform the processing described by Pasupathy, "MSK: A Spectrally Efficient
% Modulation", IEEE Comms Mag., July 1979.

% Multiply the received MSK signal by cos(pi*t/2T) and sin(pi*t/2T), where T is
% the symbol time.  The phase offsets are different for the cos and sin
% multipliers to account for the circular shift in the I channel.  These cos()
% and sin() multipliers are matched to the I and Q pulse shapes, respectively.
% Then perform receiver filtering.  Assume that the received signal already is
% properly synchronized.
arg = pi * repmat((0 : sigLen+nSamp-1)', 1, nChan) / (2*nSamp);
multSig = complex(cos(arg+pi/2) .* real(y), sin(arg-pi/2) .* imag(y));

% Perform ideal integration
filtSig = (cumsum(multSig, 1) - cumsum([zeros(2*nSamp, nChan); ...
    multSig(1:end-2*nSamp,:)], 1)) / nSamp;

% Make hard binary decisions on the I and Q channels.  Account for the fact that
% the signal vector has been augmented in length.
Istart = 2*nSamp; Qstart = 3*nSamp;
if (2*round(nBits/2) == nBits)
    Iend = sigLen; Qend = sigLen+nSamp;
else
    Iend = sigLen+nSamp; Qend = sigLen;
end
zRealDec = double(sign(real(filtSig(Istart:2*nSamp:Iend,:))));
zImagDec = double(sign(imag(filtSig(Qstart:2*nSamp:Qend,:))));

if strcmpi(dataEnc, 'diff')

    % Upsample (i.e. repeat) the I and Q channels by 2, and shift the Q channel
    % by 1 sample relative to the I channel.  This operation allows for 2 bit
    % decisions to be made over each I or Q symbol.  Also, set the threshold for
    % a suboptimal decision on the last bit.
    zRealDec = rectpulse(zRealDec, 2);
    zImagDec = rectpulse(zImagDec, 2);
    if 2*round(nBits/2) == nBits
        threshold = 0.5 * double(sign(real(filtSig(end,:))));
        zRealDec = [zRealDec(2:end,:); ...
            double(sign( real(filtSig(end,:))-threshold ))];
    else
        zRealDec = zRealDec(2:end,:);
        threshold = 0.5 * double(sign(imag(filtSig(end,:))));
        zImagDec = [zImagDec; ...
            double(sign( imag(filtSig(end,:))-threshold ))];
    end

    % Now multiply the real and imaginary parts together to find the signed data
    % values
    z = -zRealDec .* zImagDec;

else    % Nondifferentially encoded

    % Merge the I and Q data streams into one stream for each channel
    z = zeros(size(zRealDec,1)+size(zImagDec,1),nChan);
    for iChan = 1 : nChan
        zTemp = [zRealDec(:,iChan)' ; zImagDec(:,iChan)'];
        z(:,iChan) = zTemp(:);
    end

end

% Convert to unsigned values
z = (1+z)/2;

% Restore the output signal to the original orientation
if nRowsInit == 1
    z = z';
end

% Return PHASEEOUT if specified.  The value should be 0, pi/2, pi, or 3pi/2 for
% each channel.  If, through numerical errors, the phase is slightly different
% from the desired values, fix them to those desired values.
if nargout >= 2
    if strcmpi(dataEnc, 'diff')
        % Calculate phaseOut based on demodulated bits
        [dummy, phaseOut] = mskmod(z, nSamp, 'diff', ini_phase(1,:));
    else
        % Initial phase is a global phase shift for 'nondiff' mode.  We pass the
        % ini_phase as phaseOut to use for the next call.  (See mskmod.m)
        phaseOut = ini_phase(1,:);
    end
    varargout{1} = phaseOut;
end

% EOF -- mskdemod.m
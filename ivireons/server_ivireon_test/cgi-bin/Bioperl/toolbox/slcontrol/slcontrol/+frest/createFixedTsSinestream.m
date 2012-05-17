function out = createFixedTsSinestream(ts,varargin)
% frest.createFixedTsSinestream creates a frest.Sinestream signal out with fixed sample
% time ts.
%
%   out = frest.createFixedTsSinestream(ts) creates a frest.Sinestream
%   signal with fixed sample time ts. The frequencies of the sinestream
%   signal are between 1 and ws/20 where ws is the sample rate in rad/s,
%   that is, ws = 2*pi/ts. 
%  
%   out = frest.createFixedTsSinestream(ts,{wmin wmax}) creates a frest.Sinestream
%   signal with fixed sample time ts where the frequencies of the sinestream
%   signal are between wmin and wmax in rad/s.
%
%   out = frest.createFixedTsSinestream(ts,w) creates a frest.Sinestream
%   signal with fixed sample time ts where the frequencies of the sinestream
%   signal are the values in the vector w in rad/s. The values in the
%   vector w are required to be such that ws, the sample rate corresponding
%   to ts, is an integer multiple of each element in it, that is, each
%   frequency value in w should satisfy w = 2*pi/(N*ts) where N is an integer. 
%
%   out = frest.createFixedTsSinestream(ts,sys) creates a frest.Sinestream
%   signal with fixed sample time ts where the frequencies and settling
%   periods of the sinestream signal are selected based on the dynamics of
%   the LTI system sys. The frequencies are smaller than ws/20 where ws is
%   the sample rate in rad/s, that is, ws = 2*pi/ts.
%
%   out = frest.createFixedTsSinestream(ts,sys,{wmin wmax}) creates a
%   frest.Sinestream signal with fixed sample time ts where the frequencies
%   and settling periods of the sinestream signal are selected based on the dynamics of
%   the LTI system sys such that the frequencies are between wmin and wmax.
%
%   out = frest.createFixedTsSinestream(ts,sys,w) creates a
%   frest.Sinestream signal with fixed sample time ts where the settling
%   periods of the sinestream signal are selected based on the dynamics of 
%   the LTI system sys. The frequencies of the sinestream signal are the
%   values in the vector w. The values in the vector w are required to be
%   such that ws, the sample rate corresponding to ts, is an integer
%   multiple of each element in it, that is, each
%   frequency value in w should satisfy w = 2*pi/(N*ts) where N is an
%   integer.
%
%   See also frest.Sinestream, frestimate

%  Author(s): Erman Korkut 01-Apr-2009
%  Revised:
%  Copyright 2003-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2009/10/16 06:45:41 $

% Error checking
% Check number of input & output arguments
error(nargchk(1,3,nargin));
error(nargoutchk(0,1,nargout));
% Input Parsing

% The first input argument is always Ts, process the rest
sys = [];
w = [];
if nargin == 2    
    if LocalIsLTI(varargin{1})
        sys = varargin{1};
    else
        w = varargin{1};
    end
elseif nargin == 3
    if LocalIsLTI(varargin{1})
        sys = varargin{1};
        w = varargin{2};
    else
        sys = varargin{2};
        w = varargin{1};
    end
end

% Check validity of input arguments
% System
if ~isempty(sys)
    % Check system is a valid LTI system
    if ~LocalIsLTI(sys)
        % Invalid system
        ctrlMsgUtils.error('Slcontrol:frest:InvalidSystemSpecificationFixedTs');
    end
    if hasdelay(sys)
        % Use pade to avoid warnings with zero and pole
        if sys.Ts == 0
            sys = pade(sys);
        else
            sys = delay2z(sys);
        end
    end
    % Check if the system is stable
    if ~isstable(sys)
        ctrlMsgUtils.error('Slcontrol:frest:UnstableSystemSpecificationFixedTs');        
    end
end
% Frequency
if ~isempty(w)
    % Error if it is not a double array or a cell array with 2 elements
    if ~(isa(w,'double') || (iscell(w) && numel(w) == 2))        
        ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqSpecificationFixedTs');                
    end
end
% Ts
if ~(isa(ts,'double') && isscalar(ts) && ts > 0)
    ctrlMsgUtils.error('Slcontrol:frest:InvalidTsSpecificationFixedTs');    
end

% Create the sinestream signal
ws = 2*pi/ts;
if isempty(sys)
    % Manual parameter specification
    % Come up with frequency first
    if isempty(w)
        % Take the default grid up to fs/20 to guarantee 20 samples/period
        % at least        
        freq = unique(ws./(round(ws./logspace(0,log10(ws/20),30))));        
    elseif iscell(w)
        % Limit to at most 30 frequencies
        w_cand = logspace(log10(min(w{:})),log10(max(w{:})),30);
        freq = unique(ws./round(ws./w_cand));
        % Filter the ones outside the limits
        freq = freq(freq>=min(w{:}) & freq<=max(w{:}));
    else
        % Check if w is valid
        if ~LocalIsIntegerMultiple(w,ws)
            ctrlMsgUtils.error('Slcontrol:frest:NonIntegerMultipleFreqSpecificationFixedTs');
        end
        freq = unique(ws./round(ws./w));        
    end
    % Compute samples per period values
    samps = round(ws./freq);
    % Construct the sinestream object
    out = frest.Sinestream('Frequency',freq,'SamplesPerPeriod',samps,'FixedTs',ts);
else
    % Specify parameters based on a system
    % Check that sample time is compatible with system
    if (sys.Ts ~= 0) && (ts ~= sys.Ts)
        ctrlMsgUtils.warning('Slcontrol:frest:IncompatibleTsSpecificationFixedTs');
    end
    % Determine frequencies
    if isempty(w)
        freq = frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts);
        freq = unique(ws./round(ws./freq));  
        % Ignore greater than fs/20 to guarantee 20 samples/period
        freq = freq(freq<=(ws/20));
    elseif iscell(w)
        freq = frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts);       
        freq = unique(ws./round(ws./freq)); 
        % Filter out the range
        freq = freq(freq>=min(w{:}) & freq<=max(w{:}));
    else
        % Check if w is valid
        if ~LocalIsIntegerMultiple(w,ws)
            ctrlMsgUtils.error('Slcontrol:frest:NonIntegerMultipleFreqSpecificationFixedTs');
        end
        freq = unique(ws./round(ws./w));         
    end
    % Compute settling periods
    % Calculate settling times for each frequency
    settling_p = zeros(size(freq));
    % Define the gap between the amplitude response at steady state
    % and the decayed transient.
    G = freqresp(sys,freq);
    per_settle = 1;
    gap_desired = abs(G)*per_settle/100;
    % Define the frequency cutoff
    cutoff_factor = 1000;
    % Get the state space data
    [A,B,C,D] = ssdata(sys);
    Ts = sys.Ts;
    % Check against linearizations of zero: Use default values and
    % throw a warning
    if all(D(:)==0) && ((isempty(C) || all(C(:)==0)) || (isempty(B) || all(B(:)==0)))
        % Create default values
        out = frest.createFixedTsSinestream(ts);
        % Throw a warning and return
        ctrlMsgUtils.warning('Slcontrol:frest:ZeroSystemSpecification','createFixedTsSinestream');
        return;
    end
    [A,B,C] = xscale(A,B,C,D,[],Ts);
    % Compute the settle time
    for ct = 1:numel(settling_p)
        % Compute the gap for this frequency taking the maximum
        % for MIMO cases.
        thresh = gap_desired(:,:,ct);
        thresh = max(thresh(:));
        % Protect against zero threshold, taking %1 of the input
        % amplitude
        if thresh == 0
            thresh = obj.Amplitude*0.01;
        end
        settling_p(ct) = frest.Sinestream.computeSineSettleCycles(...
            A,B,C,Ts,thresh,freq(ct),cutoff_factor);
    end        
    % Compute samples per period values
    samps = round(ws./freq);
    % Construct the sinestream object
    out = frest.Sinestream('Frequency',freq,'SamplesPerPeriod',samps,...
        'SettlingPeriods',settling_p,'FixedTs',ts);
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalIsLTI
%  Check if input is an LTI system
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = LocalIsLTI(in)
bool = any(strcmp(class(in),{'ss','tf','zpk'}));
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalIsIntegerMultiple
%  Checks if "ref" is an integer multiple of all the elements in the vector
%  "values"
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bool = LocalIsIntegerMultiple(values,ref)
[n,d] = rat(ref./values);
bool = isequal(round(n./d),n./d);
end




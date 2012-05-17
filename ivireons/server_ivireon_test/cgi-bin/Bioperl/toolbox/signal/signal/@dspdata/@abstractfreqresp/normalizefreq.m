function normalizefreq(this,varargin)
%NORMALIZEFREQ   Normalize/un-normalize the frequency of the data object.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:10:08 $

[normFlag,Fs,errid,errmsg] = parseinputs(this,varargin{:});
if ~isempty(errmsg), error(errid,errmsg); end

freq = this.Frequencies;
oldFs = getfs(this);  % Cache Fs stored in the object before it gets updated.
newFsFlag = false;

% If already in the units requested, and Fs hasn't changed return early.
if ~xor(this.NormalizedFrequency, normFlag), 
    % Only proceed if user specified a different Fs.
    if isequal(oldFs,Fs),
        return;
    else
        % Convert to normalized frequency in order to scale by new Fs.
        newFsFlag = true;
        freq = freq/oldFs*(2*pi);      
    end
end

if normFlag,    freq = freq/Fs*(2*pi);   % Convert to normalized frequency.
else            freq = freq/(2*pi)*Fs;   % Convert to linear frequency.
end

if normFlag,
    this.Fs = Fs; % Set Fs first since you can't do it after it's in normalized mode.
    this.privNormalizedFrequency = normFlag; 
else
    this.privNormalizedFrequency = normFlag;  % Change to linear to allow us to set Fs.
    this.Fs = Fs;
end
this.Frequencies = freq;

% Allow concrete classes to do further manipulation of the data if necessary.
thisnormalizefreq(this,oldFs,newFsFlag);

%--------------------------------------------------------------------------
function [normFlag,Fs,errid,errmsg] = parseinputs(this,varargin)
% Parse and validate inputs.

% Setup defaults
normFlag = true;
Fs = getfs(this);
errid = '';
errmsg = '';

if nargin >= 2,
    normFlag = varargin{1};
    if nargin == 3,
        Fs = varargin{2};
    end
end
    
if nargin == 3 && normFlag
    errid = generatemsgid('invalidInputArgumentFs');
    errmsg = 'Specifying Fs is not allowed while requesting to normalize the frequency specifications.';
end

if ~islogical(normFlag),
    errid = generatemsgid('invalidLogicalFlag');
    errmsg = 'The second input argument must be a logical.';
end

% [EOF]

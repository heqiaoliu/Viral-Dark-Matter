function this = mtm(varargin)
%MTM   Thomson multitaper method (MTM) power spectral density (PSD) estimator.
%   H = SPECTRUM.MTM(TIMEBW) returns an MTM PSD estimator with the
%   time-bandwidth product set to TIMEBW. The time-bandwidth product is of
%   the discrete prolate spheroidal sequences (or Slepian sequences) used 
%   as data windows.
%
%   H = SPECTRUM.MTM(DPSS,CONCENTRATIONS) returns an mtm spectral estimator
%   with the discrete prolate spheroidal sequences and their concentrations
%   set to DPSS and CONCENTRATIONS respectively.  Type "help dpss" for more
%   information on these two input arguments.
%
%   NOTE: Specifying DPSS and CONCENTRATIONS when constructing the MTM
%   estimator automatically changes the value of the SpecifyDataWindowAs
%   property to 'DPSS' from its default value 'TimeBW'.
%
%   H = SPECTRUM.MTM(...,COMBINEMETHOD) specifies the algorithm for
%   combining the individual spectral estimates. COMBINEMETHOD can be one
%   of the following strings:
%      'Adaptive'   - Thomson's adaptive non-linear combination
%      'Eigenvalue' - linear combination with eigenvalue weights.
%      'Unity'      - linear combination with unity weights.
%
%   MTM PSD estimators can be passed to the following functions along with
%   the data to perform that function:
%       <a href="matlab:help spectrum/psd">psd</a>     - calculates the PSD
%       <a href="matlab:help spectrum/psdopts">psdopts</a> - returns options to calculate the PSD
%
%   EXAMPLES:
%
%   % Example 1: A cosine of 200Hz plus noise.
%                Fs = 1000;   t = 0:1/Fs:.3;  
%                x = cos(2*pi*t*200)+randn(size(t)); 
%                h = spectrum.mtm(3.5); % Specify the time-bandwidth product
%                                       % when creating an MTM spectral estimator.
%                psd(h,x,'Fs',Fs);      % Calculate and plot the PSD.
% 
%   % Example 2: This is the same example as above, but we'll specify the
%                % data tapers and their concetrations instead of the time BW product.
%                Fs = 1000;   t = 0:1/Fs:.3;
%                x = cos(2*pi*t*200)+randn(size(t)); 
%                [E,V] = dpss(length(x),3.5);
%                h = spectrum.mtm(E,V);    % Specify DPSS and concentrations
%                                          % when creating the MTM spectral estimator.
%                psd(h,x,'Fs',Fs);         % Calculate and plot the PSD.
%
%   See also SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2009/08/11 15:48:27 $

error(nargchk(0,4,nargin,'struct'));

% Create default MTM object.
this = spectrum.mtm;

% Defaults.
NW = 4;
combinemethod = 'Adaptive';
SpecifyDataWindowAs = this.SpecifyDataWindowAs;  % User default set in schema.
E = [];
V = [];

if nargin >= 1,
    SpecifyDataWindowAs ='TimeBW';
    NW = varargin{1};
end

if ~any(size(NW) == 1);
    % DPSS and Concentrations were specified.
    SpecifyDataWindowAs = 'DPSS';
    E = NW;
    if nargin >= 2,
        V = varargin{2};
    else
        error(generatemsgid('SignalErr'),'You must specify DPSS and Concentrations.');
    end
    % Enable the code below to depend on the same number of inputs.
    varargin(2) = [];
end

% Override default values if user specified values.
nargs = length(varargin);
if nargs >= 2,
    combinemethod = varargin{2};
end

% Set the properties of the object.
set(this,...
    'EstimationMethod', 'Thompson Multitaper',...
    'SpecifyDataWindowAs', SpecifyDataWindowAs,...
    'CombineMethod',combinemethod);

if strcmpi(SpecifyDataWindowAs,'TimeBW'),
    this.TimeBW = NW;
else
    this.DPSS = E;
    this.Concentrations = V;
end



% [EOF]

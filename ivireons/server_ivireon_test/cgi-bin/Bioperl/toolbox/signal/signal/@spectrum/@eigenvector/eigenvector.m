function this = eigenvector(varargin)
%EIGENVECTOR   Eigenvector pseudospectrum estimator.
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS) returns an eigenvector
%   pseudospectrum estimator in H with the number of complex sinusoids set
%   to the numeric value specified by NSINUSOIDS.
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH) returns an
%   eigenvector pseudospectrum estimator with the number of samples in each
%   segment set to the value specified by SEGMENTLENGTH.
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH,OVERLAPPERCENT) sets
%   the percentage of overlap between segments to the value specified by
%   OVERLAPPERCENT.
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH,OVERLAPPERCENT,...
%   WINNAME) specifies the window as a string. Use set(H,'WindowName') to
%   get a list of valid <a href="matlab:set(spectrum.eigenvector,'WindowName')">windows</a>. 
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH,OVERLAPPERCENT,...
%   {WINNAME,WINPARAMETER}) specifies the window in WINNAME and the window
%   parameter value in WINPARAMETER both in a cell array.
%
%   NOTE: Depending on the window specified by WINNAME a window parameter
%   property will be dynamically added to the eigenvector estimator H. Type
%   "help <WINNAME>" for more details.
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH,OVERLAPPERCENT,...
%   WINNAME,THRESHOLD) specifies the THRESHOLD as the cutoff for the signal
%   and noise subspace separation.
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH,OVERLAPPERCENT,...
%   WINNAME,THRESHOLD,INPUTTYPE) specifies the type of input the
%   eigenvector spectral estimator accepts. INPUTTYPE can be one of the
%   following strings:
%       'Vector'  (default)
%       'DataMatrix'
%       'CorrelationMatrix'
%
%   Eigenvector pseudospectrum estimators can be passed to the following
%   functions along with the data to perform that function:
%       <a href="matlab:help spectrum/powerest">powerest</a>           - computes the powers and frequencies of sinusoids
%       <a href="matlab:help spectrum/pseudospectrum">pseudospectrum</a>     - calculates the pseudospectrum
%       <a href="matlab:help spectrum/pseudospectrumopts.">pseudospectrumopts</a> - returns options to calculate the pseudospectrum
%
%   EXAMPLE: Spectral analysis of a signal containing complex sinusoids and
%            % noise.
%            s1 = RandStream.create('mrg32k3a');
%            n = 0:99;   
%            s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(s1,1,100);  
%            h = spectrum.eigenvector(3);   % Create an eigenvector spectral estimator.
%            pseudospectrum(h,s);           % Calculate and plot the pseudospectrum.
%
%   See also SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2008/10/31 07:03:39 $

error(nargchk(0,7,nargin,'struct'));

% Set the properties of the object.
this = spectrum.eigenvector;
set(this, 'EstimationMethod', 'Eigenvector');
initialize(this,varargin{:});

% [EOF]

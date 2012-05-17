function this = dspdata
%DSPDATA   DSP data object.
%   Hs = DSPDATA.<DATAOBJECT>(...) returns a DSP data object, Hs, of type
%   specified by DATAOBJECT. Each DATAOBJECT takes one or more inputs. 
%  
%   Below is a list of valid DATAOBJECTs (type "help dspdata.<DATAOBJECT>"
%   to get help on a specific data object - e.g., "help dspdata.psd"):
%  
%   <a href="matlab:help dspdata.msspectrum">msspectrum</a>     - Mean-square Spectrum (MSS) data object
%   <a href="matlab:help dspdata.psd">psd</a>            - Power Spectral Density (PSD) data object
%   <a href="matlab:help dspdata.pseudospectrum">pseudospectrum</a> - Pseudo Spectrum data object
%   
%   The following methods are available for the objects listed above (type
%   "help dspdata/<METHOD>" to get help on a specific method - e.g., "help
%   dspdata/avgpower"):
%
%   <a href="matlab:help dspdata/avgpower">avgpower</a>      - Average power of a PSD data object
%   <a href="matlab:help dspdata/centerdc">centerdc</a>      - Shift the zero-frequency component to center of spectrum
%   <a href="matlab:help dspdata/findpeaks">findpeaks</a>     - Local peaks in the data object
%   <a href="matlab:help dspdata/halfrange">halfrange</a>     - Pseudospectrum calculated over half the Nyquist interval
%   <a href="matlab:help dspdata/normalizefreq">normalizefreq</a> - Normalize frequency specifications
%   <a href="matlab:help dspdata/onesided">onesided</a>      - PSD or MSS calculated over half the Nyquist interval, but
%                   contains the full power
%   <a href="matlab:help dspdata/plot">plot</a>          - Plot the spectrum contained in the data object
%   <a href="matlab:help dspdata/sfdr">sfdr</a>          - Spurious free dynamic range of a MSS data object
%   <a href="matlab:help dspdata/twosided">twosided</a>      - PSD or MSS calculated over the whole Nyquist interval
%   <a href="matlab:help dspdata/wholerange">wholerange</a>    - Pseudospectrum calculated over the whole Nyquist interval
%
%   EXAMPLE: Calculate the power of a sinusoidal signal using FFT, store
%            % the results in a PSD data object, and plot it.
%
%            Fs = 32e3;   t = 0:1/Fs:2.96;
%            x  = cos(2*pi*t*10e3)+cos(2*pi*t*1.24e3)+ randn(size(t));
%            X  = fft(x);
%            P  = (abs(X).^2)/length(x)/Fs;  % Calculate power and scale to form PSD.
%  
%            hpsd = dspdata.psd(P,'Fs',Fs,'SpectrumType','twosided');
%            plot(hpsd);                     % Plot the PSD.
%
%
%   For more information see <a href="matlab:help signal">Signal Processing Toolbox TOC</a>
%
%   See also SPECTRUM.
    
%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/09/13 07:14:44 $

% Help for instantiating a DSPDATA object.

% [EOF]















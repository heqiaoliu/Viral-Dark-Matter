function hopts = psdopts(this,x)
%PSDOPTS   Power spectral density (PSD) options object.
%   Hopts = PSDOPTS(Hs) returns a PSD options object in Hopts for the PSD
%   estimator specified in Hs.
%
%   Valid PSD estimators are:
%           <a href="matlab:help spectrum.periodogram">periodogram</a>    <a href="matlab:help spectrum.mcov">mcov</a>
%           <a href="matlab:help spectrum.welch">welch</a>          <a href="matlab:help spectrum.mtm">mtm</a>
%           <a href="matlab:help spectrum.burg">burg</a>           <a href="matlab:help spectrum.yulear">yulear</a>
%           <a href="matlab:help spectrum.cov">cov</a>
%
%   Hopts contains the following properties:
%
%   Property            Valid values and description
%   ---------           ----------------------------
%   FreqPoints          [ {All} | User Defined ]
%                       Full implies full nyquist range and dynamically
%                       creates NFFT property. User Defined dynamically
%                       creates FrequencyVector property and allows the
%                       user to specify frequencies to evaluate the psd at.
%
%   NFFT                [ Auto | {Nextpow2} -or- a positive integer ]
%                       Number of FFT points. Auto uses the maximum of 256
%                       or the input (or segment for Welch) length.
%                       Nextpow2 is the same as Auto, but uses the next
%                       power of 2.
%
%   FrequencyVector     [ vector of real numeric doubles less than Fs ]
%                       Specify a vector of frequencies at which to
%                       evaluate the psd.
%
%   NormalizedFrequency [ {true} | false ]
%                       False indicates that the frequency units are in
%                       Hertz.
%
%   Fs                  [ {Normalized} -or- a positive double ]
%                       Sampling frequency which can be specified only when
%                       'NormalizedFrequency' is set to false. 
%
%   SpectrumType        [ {Onesided} | Twosided ]  
%                       Onesided indicates that the total signal power is
%                       contained in half the Nyquist range.
%
%   The Hopts object can be passed in as an input argument to the <a href="matlab:help spectrum/psd">psd</a> 
%   method.
%
%   Hopts = PSDOPTS(Hs,X) uses the data specified in X to return data
%   specific default options in Hopts.
%
%   See also SPECTRUM/MSSPECTRUMOPTS, SPECTRUM/PSEUDOSPECTRUMOPTS,
%   SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/12/27 21:30:18 $

% Help for the PSDOPTS method.

% [EOF]

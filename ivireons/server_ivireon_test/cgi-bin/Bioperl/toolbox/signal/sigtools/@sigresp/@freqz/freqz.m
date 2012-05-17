function hresp = freqz(varargin)
%FREQZ Construct a discrete-time frequency response object.
%    FREQZ(H) constructs a frequency response object with the spectrum
%    specified by the object H.  H must be an object that extends
%    DSPDATA.ABSTRACTFREQRESP.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:14:42 $

% Create a response object.
hresp = sigresp.freqz;
freqz_construct(hresp,varargin{:});
hresp.Tag  = 'freqz';
hresp.Name = 'Frequency Response';  % Title string

% [EOF]

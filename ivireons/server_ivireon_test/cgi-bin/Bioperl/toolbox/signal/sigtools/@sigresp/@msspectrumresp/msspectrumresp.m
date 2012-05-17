function hresp = msspectrumresp(varargin)
%MSSPECTRUMRESP   Construct a mean-square response object.
%    MSSPECTRUMRESP(Sxx,Fs) constructs a mean-square response object with
%    the spectrum specified by the object H.  H must be an object that
%    extends DSPDATA.ABSTRACPS.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision.3 $  $Date: 2004/01/25 23:11:23 $

% Create a response object.
hresp = sigresp.msspectrumresp;
freqz_construct(hresp,varargin{:});

% Set the name first and let the constructor overwrite it.
hresp.Name = 'Mean-square Response';  % Title string
hresp.Tag  = 'msspectrumresp';

% [EOF]

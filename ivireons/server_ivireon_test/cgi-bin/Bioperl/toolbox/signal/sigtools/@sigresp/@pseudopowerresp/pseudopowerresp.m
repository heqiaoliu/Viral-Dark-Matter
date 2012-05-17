function hresp = pseudopowerresp(varargin)
%PSEUDOPOWERRESP Construct a pseudospectrum response object.
%    PSEUDOPOWERRESP(Sxx,Fs) constructs a pseudospectrum response object
%    with the spectrum specified by the object H.  H must be an object that
%    extends DSPDATA.ABSTRACPS.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision.3 $  $Date: 2003/12/06 16:15:20 $

% Create a response object.
hresp = sigresp.pseudopowerresp;
freqz_construct(hresp,varargin{:});

% Set the name first and let the constructor overwrite it.
hresp.Name = 'Pseudospectrum Response';  % Title string
hresp.Tag  = 'pseudopowerresp';

% [EOF]

function [Pxx,W] = thispsd(this,x,opts)
%THISPSD   Power spectral density (PSD) via MTM.
%
% OPTS = {NFFT, Fs(?), and SpectrumType}.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $Date: 2007/12/14 15:14:34 $

error(nargchk(2,3,nargin,'struct'));

% Convert CombineMethod enum type to strings accepted by the function.
combineMethod = getcombinemethodstr(this);
opts = {opts{:},combineMethod};

if strcmpi(this.SpecifyDataWindowAs,'TimeBW'),
    [Pxx W] = pmtm(x,this.TimeBW,opts{:});
else
    msg = validatesizes(this,x); % Validate the size of E and V
    if ~isempty(msg), error(generatemsgid('SigErr'),msg); end
    [Pxx W] = pmtm(x,this.DPSS,this.Concentrations,opts{:});
end

%--------------------------------------------------------------------------
function msg = validatesizes(this,x)
% Return error if size mismatch is found.

msg = '';

if size(this.DPSS,2) ~= length(this.Concentrations),
     msg = ['The number of columns of DPSS (data tapers) must be',...
        ' equal to the length of the Concentration vector.'];
    return;
end

if size(this.DPSS,1) ~= length(x),
     msg = ['The length of the input data vector must equal the',...
         ' length (number of rows) of the DPSS (data tapers).'];
    return;
end

% [EOF]

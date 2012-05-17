function c = oldinputs(this)
%OLDINPUTS   Return the inputs for IMPZ and STEPZ.

%   Author(s): J. Schickler
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:11:09 $

if strcmpi(this.LengthOption, 'Specified')
    c = {this.Length};
else
    c = {[]};
end

if ~this.NormalizedFrequency
    c = {c{:}, this.Fs};
end

% [EOF]

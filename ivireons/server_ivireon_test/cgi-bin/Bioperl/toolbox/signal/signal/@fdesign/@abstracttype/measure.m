function hm = measure(this, Hd, varargin)
%MEASURE   Measure this object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:15:01 $

% Measure is only available to filter design toolbox license holders
supercheckoutfdtbxlicense(this)

error(nargchk(2,inf,nargin,'struct'));

if isempty(getfdesign(Hd))
    Hd = copy(Hd);
    setfdesign(Hd,this);
end

hm = feval(getmeasureconstructor(this), Hd, this, varargin{:});

% [EOF]

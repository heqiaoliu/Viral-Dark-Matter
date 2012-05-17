function s = getstate(this)
%GETSTATE Return the state

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/10/18 21:09:53 $

% Overloaded because it has a dynamic prop as a spec

s.Tag = class(this);
s.Version = 1;
s.freqUnits = this.freqUnits;
s.Fs        = this.Fs;
s.freqSpecType = this.freqSpecType;

p = get(this, 'DynamicSpec');

s.(p.Name) = this.(p.Name);

% [EOF]

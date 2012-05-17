function applyOptions(this, Options)
% APPLYOPTIONS  Synchronizes Response and Characteristics options

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:49 $

% Response curve preferences
applyOptions(this.Data, Options)
applyOptions(this.View, Options)

% Characteristics preferences
for ch = this.Characteristics'  % @wavechar
  applyOptions(ch.Data, Options)
  applyOptions(ch.View, Options)
end
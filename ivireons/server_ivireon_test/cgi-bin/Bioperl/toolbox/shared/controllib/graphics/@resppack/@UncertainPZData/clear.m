function clear(this)
%CLEAR  Clears data.

%  Author(s): Craig Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:24 $

[this.Data.Poles] = deal({[]});
[this.Data.Zeros] = deal({[]});

this.Ts = [];
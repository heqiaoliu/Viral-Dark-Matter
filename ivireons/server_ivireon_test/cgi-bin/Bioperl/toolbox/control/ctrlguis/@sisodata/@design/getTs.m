function Ts = getTs(this)
% Get sampling time for @design object
% Returns the sampling time from first tuned model

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:40:05 $

Ts = this.(this.Tuned{1}).getProperty('Ts');

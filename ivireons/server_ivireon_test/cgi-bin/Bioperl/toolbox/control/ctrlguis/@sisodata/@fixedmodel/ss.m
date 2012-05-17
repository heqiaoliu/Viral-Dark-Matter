function D = ss(this)
% Returns @ssdata representation of plant component.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2009/04/21 03:07:27 $

if isa(this.ModelData,'ltipack.ssdata')
    D = this.ModelData;
else
    ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
        'frddata cannot be converted to a state-space model.');
end
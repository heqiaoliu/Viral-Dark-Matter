function hout = copy(this) 
%

% COPY 
 
% Author(s): John W. Glass 08-Apr-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:30:40 $

hout = LinearizationObjects.linoptions;
fn = fieldnames(this);

for ct = 1:numel(fn)
    hout.(fn{ct}) = this.(fn{ct});
end

hout.OptimizationOptions = this.OptimizationOptions;
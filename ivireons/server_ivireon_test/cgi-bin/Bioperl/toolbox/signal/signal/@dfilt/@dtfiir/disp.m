function disp(this)
%DISP Object display.
  
%   Author: V. Pellissier
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/10/16 06:41:14 $

if length(this) > 1
    vectordisp(this);
    return;
end

fn = fieldnames(this);

nidx = [3, 7, 5, 6, 1];


if this.PersistentMemory,
    % display states
    nidx = [nidx, 4];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn, 20);

disp(this.filterquantizer, 20);

% [EOF]

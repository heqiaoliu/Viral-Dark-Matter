function disp(this)
%DISP Object display.
  
%   Author: V. Pellissier, M.Chugh
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/10/14 16:24:47 $

if length(this) > 1
    vectordisp(this);
    return;
end

fn = fieldnames(this);
N = length(fn);
% Reorder the fields.
if N>6, N=6; end
nidx = [3, 5:N, 1];
if this.PersistentMemory,
    % display states
    nidx = [nidx, 4];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn, 20);

disp(this.filterquantizer, 20);
% [EOF]

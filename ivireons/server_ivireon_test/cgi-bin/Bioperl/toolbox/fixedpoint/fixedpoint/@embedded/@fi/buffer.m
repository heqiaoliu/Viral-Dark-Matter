function varargout = buffer(this,nSamps)
%BUFFER Buffer a signal vector into a matrix of data frames
%  Refer to the Signal Processing Toolbox BUFFER reference page for more
%  information.
%
%  See also BUFFER 

%   Copyright 1999-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/10 21:32:59 $
% buffer(x,n) == reshape([x(:); zeros(n-rem(length(x),n),1)],n,[]) 

if ~license('test','Signal_Toolbox')
  error('fi:buffer:noSignalLicense',...
        'There must be a Signal Toolbox license available to use the buffer command with fi objects.');
end

error(nargoutchk(0,2,nargout,'struct'));

[m,n] = size(this);
if (m ~= 1 && n~= 1) || this.numberofelements == 0
  error('fi:buffer:notVector',...
        'Cannot buffer matrix-valued fi object; must be a row or column vector');
end

tmp = reshape(this,m*n,1);
if nargout < 2
  varargout = cell(1);
  pad = nSamps-rem(m*n,nSamps);
  if pad < nSamps % pad == nSamps => no pad needed
    varargout{1} = reshape([tmp; zeros(pad,1)],nSamps,[]);
  else
    varargout{1} = reshape(tmp,nSamps,[]);
  end
else
  len = nSamps*floor(m*n/nSamps);
  varargout = cell(1,2);
  y = subscriptedreference(tmp,0:len-1);
  varargout{1} = reshape(y,nSamps,[]);
  z = subscriptedreference(this,len:m*n-1);
  varargout{2} = z;
end

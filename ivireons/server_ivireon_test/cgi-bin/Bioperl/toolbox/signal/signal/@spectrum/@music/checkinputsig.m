function [x,nchans,msg] = checkinputsig(this,x)
%CHECKINPUTSIG   Return the input vector column'ized & number of channels.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:17:30 $

msg = '';
[lenX,nchans] = size(x);
xIsMatrix = ~any([lenX,nchans]==1);

if strcmpi(this.InputType, 'Vector') & xIsMatrix, 
    msg = 'Multi-channel data (matrices) is not supported when the InputType property is set to Vector.';
    return;
    
elseif ~xIsMatrix,
    x = x(:);   % Column'ize it.
    [lenX,nchans] = size(x);
end 

% [EOF]

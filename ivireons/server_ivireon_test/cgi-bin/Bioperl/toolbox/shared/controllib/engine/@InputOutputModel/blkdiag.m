function sys = blkdiag(varargin)
%BLKDIAG  Block-diagonal concatenation of input/output models.
%
%   M = BLKDIAG(M1,M2, ...) returns the aggregate model:
% 
%                 [ M1  0  .. 0 ]
%             M = [  0  M2      ]
%                 [  :      .   ]
%                 [  0        . ]
%
%   BLKDIAG is another name for APPEND.
%
%   See also APPEND, SERIES, PARALLEL, FEEDBACK, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:22 $
try
   sys = append(varargin{:});
catch ME
   error(ME.identifier,strrep(ME.message,'append','blkdiag'))
end

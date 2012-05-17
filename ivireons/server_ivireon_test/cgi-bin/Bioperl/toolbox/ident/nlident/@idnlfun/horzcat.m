function C = horzcat(varargin)
%HORZCAT Horizontal concatenation of IDNLFUN objects

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:31 $

% Author(s): Qinghua Zhang

if nargin==1
    C = varargin{1};
    return
end

ss = cellfun(@numel, varargin)';

objcells = cell(sum(ss),1);
pt = 0;
for k=1:nargin
    if ~isa(varargin{k}, 'idnlfun')
        ctrlMsgUtils.error('Ident:combination:NLWithOtherObjects')
    end
    
    if isa(varargin{k}, 'idnlfunVector')
        objcells(pt+1:pt+ss(k)) = varargin{k}.ObjVector;
        pt = pt + ss(k) ;
    else
        pt = pt + 1;
        objcells{pt} = varargin{k};
    end
end

% objclasses = cellfun(@class, objcells, 'UniformOutput', false) ;
% if isequal(objclasses{:})
%   % Use ordinary object array for homogeneous objects
%   C = builtin('vertcat', objcells{:});
% else
%   C = idnlfunVector(objcells{:});
% end

% Note: it is decided that idnlfunVector is always used, even for
% homogeneous objects, there for the above code is replaced by the single line:

C = idnlfunVector(objcells{:});

% FILE END

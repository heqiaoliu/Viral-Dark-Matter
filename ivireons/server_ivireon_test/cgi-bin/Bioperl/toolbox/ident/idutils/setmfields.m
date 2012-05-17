function s = setmfields(s, fnames, fvalues)
%SETMFIELDS sets multiple fields of a scalar structure
%  s = setmfields(s, fnames, fvalues)
%  s is a structure
%  fnames and fvalues are cell arrays containing field names and values.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:51:58 $

error(nargchk(3,3, nargin,'struct'))
error(nargoutchk(1,1, nargout,'struct'))

if ~iscellstr(fnames)
    ctrlMsgUtils.error('Ident:utility:setmfields1')
end

nf = numel(fnames);

if ~iscell(fvalues) || numel(fvalues)~=nf
    ctrlMsgUtils.error('Ident:utility:setmfields2')
end

for kf=1:nf
    s.(fnames{kf}) = fvalues{kf};
end

% FILE END
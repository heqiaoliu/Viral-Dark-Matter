function hChild = getcomponent(hParent, tag, varargin)
%GETCOMPONENT Retrieve a component handle from the container
%   GETCOMPONENT(hOBJ, TAG) Retrieve a component handle from the container
%   by searching for its tag.
%
%   GETCOMPONENT(hOBJ, PROP, VALUE, PROP2, VALUE2, ...) Retrieve a component
%   handle from the container by searching according to property value pairs.
%
%   GETCOMPONENT returns an empty vector if the object is not found.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2007/12/14 15:21:32 $

msg = nargchk(2,inf,nargin);

if nargin > 2,
    if ~rem(length(varargin),2),
        msg = 'Not enough input argument.';
    else
        varargin = {tag, varargin{:}};
    end
elseif nargin > 1,
    varargin = {'Tag', tag};
end
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

hChild = get(hParent, 'SigguiComponents');

if ~isempty(hChild),
    hChild = find(hChild, '-depth', 1, varargin{:});
end

% [EOF]

function hCopy = copy(this, childFlag)
%COPY     Copy this object

% This method is overloaded to force the default (no input) constructors to
% be called.  This is needed for PropertyDb and ConfigDb to attach the
% listeners to the ObjectChildAdded and ObjectChildRemoved.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:46 $

% Construct a new object.
hCopy = feval(class(this));

% Copy the public interface.
publicProps = get(this);
if ~isempty(publicProps)
    set(hCopy, publicProps);
end

% Copy the children if the 'children' flag is passed.
if nargin > 1 && strcmp(childFlag, 'children')
    hAll = allChild(this);
    for indx = 1:length(hAll)
        hCopy.add(copy(hAll(indx), 'children'));
    end
end

% [EOF]

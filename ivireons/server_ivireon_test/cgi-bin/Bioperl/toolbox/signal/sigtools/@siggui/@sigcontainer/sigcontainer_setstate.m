function sigcontainer_setstate(hParent, s)
%SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2007/12/14 15:19:36 $

error(nargchk(2,2,nargin,'struct'));

fields = fieldnames(s);

for indx = 1:length(fields),
    hChild = getcomponent(hParent, '-class', ['siggui.' fields{indx}]);
    if ~isempty(hChild),
        setstate(hChild, s.(fields{indx}));
        s = rmfield(s, fields{indx});
    end
end

siggui_setstate(hParent, s);

% [EOF]

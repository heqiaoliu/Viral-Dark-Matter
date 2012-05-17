function [props, descs] = abstractgetbuttonprops(h)
%ABSTRACT_GETBUTTONPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:42:06 $

p = find(h.classhandle.properties, '-not', 'Description', '');

if isempty(p),
    props = {};
    descs = {};
else
    props = get(p, 'Name');
    descs = get(p, 'Description');
end

% [EOF]

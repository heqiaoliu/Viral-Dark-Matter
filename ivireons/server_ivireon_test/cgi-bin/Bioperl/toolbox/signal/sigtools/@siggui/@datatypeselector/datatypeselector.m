function this = datatypeselector(suggested, fraclength)
%DATATYPESELECTOR Constructs a datatype selector object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2007/12/14 15:18:15 $

% Instantiate the object
this = siggui.datatypeselector;

if nargin
    set(this, 'SuggestedType', suggested);
    if nargin > 1
        if length(fraclength) > 1
            error(generatemsgid('InvalidParam'),'Invalid Input.');
        end
        set(this, 'FractionalLength', fraclength);
    end
end

% [EOF]

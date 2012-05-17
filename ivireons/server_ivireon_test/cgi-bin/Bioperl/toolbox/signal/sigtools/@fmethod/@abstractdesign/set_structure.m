function struct = set_structure(this, struct)
%SET_STRUCTURE   PreSet function for the 'structure' property.

%   Author(s): J. Schickler
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:38:23 $

% '' is a special case that is always valid.  It is the default defined by
% each subclass.
if isempty(struct)
    return;
end

% Check if the structure is valid here.  We do not use an enumerated type
% because we want to customize the error message.
if ~any(strcmpi(struct, getvalidstructs(this)))
    try
        % Try/catch the given structure.  If this also fails we know that
        % they gave us an mfilt or an invalid structure name.
        feval(['dfilt.' struct]);
    catch
        try 
            % Try/catch the structure as an mfilt. If this also fails we know that
            % they gave us an invalid structure name.
            feval(['mfilt.' struct]);
        catch
            error(generatemsgid('invalidStructure'), ...
                sprintf('''%s'' is not a valid filter object name', struct));
        end
    end

    % If we've made it this far it must be because struct is a valid
    % structure name, but not for this design method.
    error(generatemsgid('invalidStructure'), ...
        sprintf('''%s'' is an invalid structure for this design.', struct));
end

% [EOF]

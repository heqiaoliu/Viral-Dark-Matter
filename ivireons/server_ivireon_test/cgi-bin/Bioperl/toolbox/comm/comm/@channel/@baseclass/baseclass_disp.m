function baseclass_disp(h, props)
%BASECLASS_DISP  Object display.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/11 15:56:55 $

% If h is a vector, use the built-in disp method
if isscalar(h)
    error(nargchk(1, 2, nargin,'struct'));
    
    % Create a structure, g, whose field names and field values are equal to
    % the object's property names and property values, respectively.
    g = get(h);
    
    if nargin==2  % Property list specified        
        % Build a new structure, s, containing fields listed in the cell array
        % 'props'. Set the field values to the respective field values of g.
        % Remove fields of g which exist in s, thus leaving g with fields that
        % don't appear in s.
        for n = 1:length(props)
            x = props{n};
            s.(x) = g.(x);
            g = rmfield(g, x);
        end        
    else        
        % Structure uses *all* object properties.
        s = g;        
    end    
    % Display the structure.
    disp(s);
else
    builtin('disp', h);
end

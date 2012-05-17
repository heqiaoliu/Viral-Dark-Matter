function abstractDemodDisp(h, fn)
%ABSTRACTDEMODDISP Display object properties in the given order

%   @modem/@abstractDemodDisp

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 15:57:06 $

% If h is a scalar, display properties in a predefined order, otherwise, use the
% built-in display method
if isscalar(h)
    % build a structure with customized ordering of properties
    s = get(h);
    
    if strcmpi(h.DecisionType, 'hard decision')
        s = rmfield(s, 'NoiseVariance');
        fn = fn(~strcmp(fn, 'NoiseVariance'));
    end
    
    % perform custom ordering of structure
    s = orderfields(s, fn);
    
    % display the resulting structure
    disp(s);
else
    builtin('disp', h);
end
%-------------------------------------------------------------------------------
% [EOF]

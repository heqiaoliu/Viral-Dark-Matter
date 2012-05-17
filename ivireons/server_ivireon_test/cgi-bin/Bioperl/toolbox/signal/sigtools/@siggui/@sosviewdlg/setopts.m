function setopts(this, opts)
%SETOPTS   Set the opts.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/10/18 21:10:41 $

type = lower(get(opts, 'View'));

set(this, 'ViewType', type);
switch type
    case 'custom'
        custom = get(opts, 'UserDefinedSections');

        % Format the custom settings into a string.
        if iscell(custom)
            customstr = '{';
            for indx = 1:length(custom)
                customstr = sprintf('%s%s, ', customstr, mat2str(custom{indx}));
            end
            customstr(end-1:end) = [];
            customstr = sprintf('%s}', customstr);

        else
            customstr = mat2str(custom);
        end
        
        set(this, 'Custom', customstr);
    case 'cumulative'
        
        % Convert the boolean secondaryscaling to 'on/off'
        if opts.SecondaryScaling
            ss = 'on';
        else
            ss = 'off';
        end
        set(this, 'SecondaryScaling', ss);
end

set(this, 'isApplied', true);

% [EOF]

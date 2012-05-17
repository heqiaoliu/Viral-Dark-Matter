function names = getnames(this, Hd)
%GETNAMES   Get the names.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/06/13 15:29:34 $

nsecs = nsections(Hd);

alltypes = set(this, 'View');

switch this.View
    case alltypes{1}, % 'complete'
        names = {''};
    case alltypes{2}, % 'individual'
        for indx = 1:nsecs
            names{indx} = sprintf('Section #%d', indx);
        end
    case alltypes{3}, % 'cumulative'
        names = {sprintf('Section #%d',1)};
        for indx = 2:nsecs
            names{indx} = sprintf('Sections #1-%d', indx);
        end
    case alltypes{4}, % 'userdefined'
        custom = trimcustom(this, Hd);

        for indx = 1:length(custom)
            if length(custom{indx}) == 1,
                
                % If there is just one section print it.
                names{indx} = sprintf('Section #%d', custom{indx});
            elseif all(diff(custom{indx}) == 1)
                    
                % If we have consecutive sections use a '-'
                names{indx} = sprintf('Sections #%d-%d', min(custom{indx}), max(custom{indx}));
            else

                % If the sections aren't consecutive use [].
                names{indx} = 'Sections #[';
                for jndx = 1:length(custom{indx}),
                    names{indx} = sprintf('%s%d ', names{indx}, custom{indx}(jndx));
                end
                names{indx} = sprintf('%s]', names{indx}(1:end-1));
            end
        end
end

% [EOF]

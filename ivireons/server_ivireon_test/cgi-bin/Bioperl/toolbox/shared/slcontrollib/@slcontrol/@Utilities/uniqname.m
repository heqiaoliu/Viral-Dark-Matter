function s1 = uniqname(this,s0,truncate)
%UNIQNAME determines the shortest unique value for each name in a set
%   UNIQNAME(this,NAMES,TRUNCATE) looks through the cell array of Simulink
%   block names provided in Names and first adds indices to repeated
%   elements.  This is done by adding (ind) to the end of each repeated
%   element.  If the TRUNCATE flag is true then the routine determines the
%   shortest string that uniquely represents each block. These names are
%   then used in NAMES.
%
%   This is the old function uniqname used with the CSTB modified to handle
%   user defined /'s in the block path.

%   Greg Wolodkin, 7-23-98
%   Modified John Glass 10-2-2004
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/10/31 06:58:41 $

% Starting with a cell array of Simulink block names,
% remove newlines and as many system/subsystem names
% as possible from each entry such that the list of
% names is still unique

% Convert the cell array to column if it is row
s0 = s0(:);

N = length(s0);

if isequal(N,0),
    s1=s0;
    return
end

% Strip out newlines
s1 = regexprep(s0,'\n',' ');

% Sort so that we can unsort later
[stmp,ox] = sort(s1);
[junk,px] = sort(ox);

% Some names may be identical (any block with more than one state..)
% In that case, use (1), (2), etc. to differentiate them.
[xx,ix,jx] = unique(stmp);
for k=1:N
    if jx(k) > 0
        kx = find(jx==jx(k));
        if length(kx) > 1
            for n=1:length(kx)
                stmp{kx(n)} = [stmp{kx(n)} '(' int2str(n) ')'];
            end
            jx(kx) = zeros(size(kx));
        end
    end
end
stmp = stmp(px,1);			% undo the first sort

if truncate
    % Now start stripping subsystem names
    done = 0;
    umask = Inf*ones(N,1);

    while ~done
        for k=1:N
            if umask(k) > 0
                % Find the subsystem division lines
                xx = regexp(stmp{k},'[^/][/][^/]');
                xx = xx + 1;
                umask(k) = min(length(xx), umask(k));
                s1{k} = stmp{k}(xx(umask(k))+1:end);
            else
                s1{k} = stmp{k};
            end
        end

        % Sort so that we can unsort later
        [s2,ox] = sort(s1);
        [junk,px] = sort(ox);

        % build the next umask
        [xx,ix,jx] = unique(s2);
        if length(xx) == N		 	% already unique
            done = 1;
        else
            for k=1:N
                if jx(k) > 0
                    kx = find(jx==jx(k));
                    if length(kx) > 1
                        umask(ox(kx)) = umask(ox(kx)) - 1;
                    end
                    jx(kx) = zeros(size(kx));
                end
            end
        end
    end
    s1 = s2(px);
else
    s1 = stmp;
end



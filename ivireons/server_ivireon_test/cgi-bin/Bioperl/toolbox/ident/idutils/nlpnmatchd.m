function [Property,imatch] = nlpnmatchd(varargin)
%NLPNMATCHD  Matches property name against property list.
%
%   PROPERTY = NLPNMATCHD(NAME, PLIST) matches the string NAME
%   against the list of property names contained in PLIST.
%   If there is a unique match, PROPERTY contains the full
%   name of the matching property.  Otherwise an error message
%   is issued. NLPNMATCH uses case-insensitive string comparisons.
%
%   PROPERTY = NLPNMATCHD(NAME, PLIST, N) limits the string
%   comparisons to the first N characters.
%
% Note: NLPNMATCHD is the same as PNMATCHD, except for the extra shortcut
%       'nl'='nonlinear'.

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:08:32 $

% Author(s): Qinghua Zhang

% Check that the function is called with 2, 3, or 4 input arguments.
error(nargchk(2, 4, nargin, 'struct'))

Name = varargin{1};
if ischar(Name)
    Name = lower(strtrim(Name));
    lenname = length(Name);
    ind = strfind(Name, 'nl');
    if ~isempty(ind)
        ind = ind(1); % Keep the first one if multiple occurrences are found.
        if ((ind == 1) || ismember(Name(1:ind-1), {'u', 'y', 'input', 'output'}))
            if (lenname == ind+1)
                varargin{1} = [Name(1:ind-1) 'Nonlinearity'];
            else
                varargin{1} = [Name(1:ind-1) 'Nonlinear' Name(ind+2:end)];
            end
        end
    end
end

[Property, imatch] = pnmatchd(varargin{:});

% FILE END

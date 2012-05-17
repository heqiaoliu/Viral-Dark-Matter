function [Property, imatch] = pnmatchd(Name, PropList, nchars, extend)
%PNMATCHD  Matches property name against property list.
%
%   PROPERTY = PNMATCHD(NAME, PLIST) matches the string NAME
%   against the list of property names contained in PLIST.
%   If there is a unique match, PROPERTY contains the full
%   name of the matching property.  Otherwise an error message
%   is issued. PNMATCH uses case-insensitive string comparisons.
%
%   PROPERTY = PNMATCHD(NAME,PLIST,N) limits the string
%   comparisons to the first N characters.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.11.4.9 $ $Date: 2008/10/02 18:51:53 $

% Check number of inputs.
ni = nargin;
if (ni < 4)
    extend = true;
end
if (~ischar(Name) || (size(Name, 1) > 1))
    ctrlMsgUtils.error('Ident:general:invalidPropertyName2')
end

% Set number of characters used for name comparison.
% Handle shortcuts.
if extend
    if strcmpi(Name, 'u')
        Name = 'InputData';
    end
    if strcmpi(Name(1), 'u')
        if strcmpi(Name, 'un')
            ctrlMsgUtils.error('Ident:general:ambiguousPropWithInfo',Name,'UName Units')
        end
        if ~strcmpi(Name(2), 's')
            if ((length(Name) < 3) || ((length(Name) > 2) && ~strcmpi(Name(1:3), 'uni')))
                Name = ['Input' Name(2:end)];
            end
        end
    end
    if strcmpi(Name, 'y')
        Name = 'OutputData';
    end
    if strcmpi(Name(1),'y')
        Name = ['Output' Name(2:end)];
    end
end

% backward compatibility of SearchDirection
Name = LocalManageBackwardCompat(Name,PropList);

if (ni < 3)
    nchars = length(Name);
else
    nchars = min(nchars, length(Name));
end


% Find all matches.
imatch = find(strncmpi(Name, PropList, nchars));

% Get matching property name.
switch length(imatch)
    case 1
        % Single hit.
        Property = PropList{imatch};
    case 0
        % No hit.
        ctrlMsgUtils.error('Ident:utility:invalidProperty',Name)
    otherwise
        % Multiple hits. Take shortest match provided it is contained
        % in all other matches (Xlim and XlimMode as matches is OK, but
        % InputName and InputGroup is ambiguous).
        [minlength, imin] = min(cellfun('length', PropList(imatch)));
        Property = PropList{imatch(imin)};
        if ~all(strncmpi(Property, PropList(imatch), minlength))
            snam = '';
            for kl = imatch(:)'
                snam = [snam(:)' PropList{kl} ' '];
            end
            ctrlMsgUtils.error('Ident:general:ambiguousPropWithInfo',Name,snam)
        end
        imatch = imatch(imin);
end

%--------------------------------------------------------------------------
function Name = LocalManageBackwardCompat(Name,proplist) 
% check for obsolete property access

% backward compatibility of SearchDirection
if strncmpi(Name,'SearchDirection',7)  && any(strcmp(proplist,'SearchMethod'))
    ctrlMsgUtils.warning('Ident:idmodel:obsoletePropSearchDir')
    Name = 'SearchMethod';
end

% backward compatibility of Trace
if strncmpi(Name,'Trace',max(length(Name),2)) && ~any(strcmpi(proplist,'det')) && any(strcmp(proplist,'Display'))
    ctrlMsgUtils.warning('Ident:idmodel:obsoletePropTrace')
    Name = 'Display';
end

% backward compatibility of Trace
if strncmpi(Name,'Approach',max(length(Name),2)) 
    ctrlMsgUtils.error('Ident:idmodel:obsoletePropApproach')
end

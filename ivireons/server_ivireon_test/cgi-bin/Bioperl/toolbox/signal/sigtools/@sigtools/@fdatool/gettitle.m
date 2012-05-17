function title = gettitle(hFDA,level)
%GETTITLE Returns the title of FDATool.
%   TITLE = GETTITLE(HFDA) Returns the title of the FDATool session
%   specified by HFDA.  This title will be 'Filter Design & Analysis 
%   Tool - ' followed by the filename of the session.  The file dirty
%   marker can be displayed in this default mode.
%
%   If a host exists then the title specified by the host will be
%   used.  If omitted or not specified, the filename of the session
%   is used.  The file dirty marker is only displayed if a filename
%   is use.  The host can replace both 'Filter Design & Analysis
%   Tool - ' and the filename with a string of its choice.
%
%   SUBTITLE = GETTITLE(HFDA,'subtitle') Returns the subtitle of the
%   FDATool session specified by HFDA (e.g. '[fdatool.fda]').
%
%   FIGTITLE = GETTITLE(HFDA,'figtitle') Returns the figtitle of the
%   FDATool session specified by HFDA.
%
%   See also SETTITLE

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2007/12/14 15:21:13 $ 

error(nargchk(1,2,nargin,'struct'));

if nargin == 1
    subtitle = getsubtitle(hFDA);
    figtitle = getfigtitle(hFDA);
    title = [figtitle, ' ', subtitle];
elseif strcmpi(level,'subtitle')
    title = getsubtitle(hFDA);
elseif strcmpi(level,'figtitle')
    title = getfigtitle(hFDA);
end

%---------------------------------------------------------------------
function subtitle = getsubtitle(hFDA)
% Returns the subtitle to FDATool.  This is the filename by default, but 
% it can be set with SETTITLE

subtitle = get(hFDA, 'SubTitle');
if isempty(subtitle),
    
    % In case there is no host, or caller does not want to supply title use
    % the filename and show the dirtymarker (if appropriate).
    subtitle = get(hFDA, 'filename');
    
    maxStrLen = 50;
    if length(subtitle) > maxStrLen
        subtitle = ['...' subtitle(end-maxStrLen:end)];
    end
    
    if get(hFDA, 'FileDirty'),
        subtitle = [subtitle ' *'];
    end
    subtitle = ['[' subtitle ']'];
end

%---------------------------------------------------------------------
function figtitle = getfigtitle(hFDA)
% Returns the figtitle to FDATool.  This is 'Filter Design & Analysis Tool'
% by default, but it can be set with SETTITLE

figtitle = get(hFDA, 'FigureTitle');
if isempty(figtitle),

    % In case there is no host, or caller does not want to supply title
    figtitle = 'Filter Design & Analysis Tool - ';
end


% [EOF]

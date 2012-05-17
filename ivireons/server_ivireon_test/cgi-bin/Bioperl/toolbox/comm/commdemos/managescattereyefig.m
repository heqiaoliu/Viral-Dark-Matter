function managescattereyefig(hFig, varargin)
% Move scattereyedemo figures
%
% MANAGESCATTEREYEFIG(HFIG)
%   Move regular figures, including scatter plots, pointed by HFIG
%
% MANAGESCATTEREYEFIG(HFIG, HEYE)
%   Move regular figures, including scatter plots, pointed by HFIG, and
%   eyediagram scopes pointed by HEYE to the default position 'right'.  
%
% MANAGESCATTEREYEFIG(HFIG, HEYE, POS)
%   Move regular figures, including scatter plots, pointed by HFIG, and
%   eyediagram scopes pointed by HEYE, based on the position argument POS.
%   POS can be:
%       right - place the figures horizontally to the right of the previous
%               figure.  If only HFIG or HEYE is specified, then place two
%               figures side by side.  If both specified, then place HFIG to the
%               right of the HEYE.
%       left  - place the figures horizontally to the left of the previous
%               figure.  If only HFIG or HEYE is specified, then place two
%               figures side by side.  If both specified, then place HFIG to the
%               left of the HEYE.
%       down  - place the figures vertically below the previous figure.  If only
%               HFIG or HEYE is specified, then place two figures on top of each
%               other.  If both specified, then place HFIG below the HEYE.

% Copyright 1996-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/05/20 01:58:28 $

% Check if handle for eyediagram(s) is defined
if nargin > 1
    hEye = varargin{1};
else
    hEye = [];
end

% Check if position is defined
if nargin == 3
    pos = varargin{2};
else
    pos = 'right';
end

numFig = length(hFig);
numEye = length(hEye);

if ( numEye )
    % There are more than zero eye diagrams. Get the scope handles and place the
    % handles in a vector
    hEyeFigTemp = get(hEye, 'PrivScopeHandle');
    if ( iscell(hEyeFigTemp) )
        for p=1:length(hEyeFigTemp)
            hEyeFig(p) = hEyeFigTemp{1}; %#ok<AGROW>
        end
    else
        hEyeFig = hEyeFigTemp;
    end
end

if ( numEye )
    % There are more than zero eye diagrams. Place them side-by-side starting
    % from the left of the screen
    ep1 = get(hEyeFig(1), 'position');
    movefigures(hEyeFig, [0 0; ep1(3)+10 0]);
    
    if ( numFig )
        % There are also other figures (scatter plots or signal plots).  Place
        % them according to the position argument POS
        switch ( pos )
            case 'right',
                movefigures(hFig, [ep1(3)+10 0; ep1(3)+10 0]);
            case 'left',
                set(hFig, 'Position', get(hEyeFig, 'Position'))
                movefigures(hEyeFig, [ep1(3)+10 0; ep1(3)+10 0]);
            case 'down',
                ep2 = get(hEyeFig(2), 'position');
                sp1 = get(hFig(1), 'position');
                sp2 = get(hFig(2), 'position');
                movefigures(hFig, ...
                    [(ep1(3)-sp1(3))/2-5 ep1(4); ...
                    ep2(1)+(ep2(3)-sp2(3))/2-5 ep2(4)]);
        end
    end
else
    % There are no eye diagrams, but just figures.  Place them according to the
    % position argument POS
    fp = get(hFig(1), 'position');
    switch ( pos )
        case 'right',
            movefigures(hFig, [0 0; fp(3)+10 0]);
        case 'down',
            movefigures(hFig, [0 0; 0 fp(4)]);
    end
end

%-------------------------------------------------------------------------------
function movefigures(h, offset)
% Move the figures with the offset value.  The reference point is 
% upper corner y: ss(4)*0.9 => 90% of the screen length
% upper corner x: 5

ss = get(0,'ScreenSize');

numFig = length(h);
fp1 = get(h(1),'position');
% If the offset pushes the first figure out of the screen, then bring the figure
% back into the screen
offset(1,:) = checkoffset(offset(1,:), fp1, ss);
set(h(1),'position',[5+offset(1,1) ss(4)*.9-fp1(4)-offset(1,2) fp1(3) fp1(4)]);


if numFig == 2
    fp2 = get(h(2),'position');
    % If the offset pushes the second figure out of the screen, then bring the
    % figure back into the screen
    offset(2,:) = checkoffset(offset(2,:), fp2, ss);
    set(h(2),'position',[5+offset(2, 1) ss(4)*.9-fp2(4)-offset(2, 2) fp2(3) fp2(4)]);
end

%-------------------------------------------------------------------------------
function offset = checkoffset(offset, fp, ss)
% Make sure that the offset will not push the figure out of the screen

if ( (5+offset(1,1)+fp(3)) > ss(3) )
    offset(1,1) = ss(3) - fp(3);
end
if ( (ss(4)*.9-fp(4)-offset(1,2)) < ss(4)*.05 )
    offset(1,2) = ss(4)*0.85 - fp(4);
end
        
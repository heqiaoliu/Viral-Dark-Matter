function sz = gui_sizes(hSuper)
%GUI_SPACING Returns a structure of spacings and generic sizes

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:25:55 $

pf = get(0,'screenpixelsperinch')/96;
if isunix,
    pf = 1;
end
sz.pixf = pf;

% Spacing
sz.vfus = 5*pf;     % vertical space between frame and uicontrol 
sz.hfus = 10*pf;    % horizontal space between frame and uicontrol 
sz.ffs  = 5*pf;     % frame/figure spacing and horizontal frame/frame spacing
sz.vffs = 15*pf;    % vertical space between frame and frame
sz.lfs  = 10*pf;    % label/frame spacing
sz.uuvs = 10*pf;    % uicontrol/uicontrol vertical spacing
sz.uuhs = 10*pf;    % uicontrol/uicontrol horizontal spacing

% Sizes
sz.ebw  = 90*pf;    % edit box width
sz.bh   = 20*pf;    % pushbutton heightsz.bw   = 165; % button width
sz.tw   = 100*pf;   % text width

% Unix needs a bigger fontsize
if ispc, sz.fontsize = 8;
else,    sz.fontsize = 10; end

lang = get(0, 'language');
if strncmpi(lang, 'ja', 2)
    sz.fontsize = sz.fontsize+2; end
    
sz.lh = (sz.fontsize+10)*pf;  % label height
sz.uh = sz.lh;

% Tweak factors
sz.lblTweak = 3*pf; % text ui tweak to vertically align popup labels
sz.popwTweak = 22*pf;  % Extra width for popup
sz.rbwTweak  = 22*pf;  % Extra width for radio button

% [EOF]

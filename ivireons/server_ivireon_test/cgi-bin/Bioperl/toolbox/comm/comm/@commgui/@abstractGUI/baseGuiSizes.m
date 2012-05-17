function sz = baseGuiSizes(this) %#ok
%BASEGUISIZES Returns a structure of spacings and generic sizes

%   @commgui/@abstractGUI
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/07/14 03:52:20 $

pf = get(0,'screenpixelsperinch')/96;
if isunix,
    pf = 1;
end
sz.pixf = pf;

% Spacing
sz.hel = 10*pf;     % horizontal spacing between elements and labels
sz.hcc = 10*pf;     % horizontal spacing between control and control
sz.vcc = 10*pf;     % vertical spacing between control and control
sz.hcl = 10*pf;     % horizontal spacing between control and label
sz.hcf = 10*pf;     % horizontal spacing between control and frame
sz.vcf = 10*pf;     % vertical spacing between control and frame
sz.hff = 10*pf;     % horizontal spacing between frame and frame/figure
sz.vff = 15*pf;     % vertical spacing between frame and frame/figure

% Sizes
sz.tbh  = 15*pf;    % text box height
sz.ebw  = 90*pf;    % edit box width
sz.bh   = 25*pf;    % pushbutton height
sz.bw   = 75*pf;    % pushbutton width
sz.tw   = 100*pf;   % text width
sz.tbh  = 20*pf;    % toolbar height
sz.tcs  = 2*pf;     % table column separation

% Unix needs a bigger font size
if ispc
    sz.fs = 8;
else
    sz.fs = 10; 
end

lang = get(0, 'language');
if strncmpi(lang, 'ja', 2) && 0 % We need to turn this off until GUI is localized
    sz.fs = sz.fs+2; end
    
sz.lh = (sz.fs+10)*pf;  % label height

sz.MenuHeight = 21*pf;  % Height of the menu bar

% Tweak factors
sz.lblTweak = 3*pf;   % text ui tweak to vertically align popup labels
sz.puwTweak = 22*pf;  % Extra width for popup
sz.rbwTweak = 15*pf;  % Extra width for radio button
sz.sbTweak = -(sz.vcc - 2*pf);  % Reduced vertical distance for slider bar labels
sz.plTweak = 7*pf;    % Extra vertical distance to align the panel frame
sz.ptTweak = 15*pf;   % Extra vertical distance at the top of the panel and its components
sz.bwTweak = 5*pf;    % Width for a tight button
sz.lbwTweak = 15*pf;  % The horizontal space occupied by listbox scroll bar
sz.ptbTweak = 3*pf;   % space between panel and textbox inside
sz.lbhTweak = 10*pf;  % Label height tweak
sz.tbl1clTweak = 34*pf; % The width of the first column of the uitable that 
                      % needs to be subtracted from the table width to get the
                      % available width

%-------------------------------------------------------------------------------
% [EOF]

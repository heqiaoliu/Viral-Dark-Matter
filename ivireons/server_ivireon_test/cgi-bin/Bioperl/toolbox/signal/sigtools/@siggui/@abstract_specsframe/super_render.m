function super_render(this, varargin)
%RENDER Render the specifications frame GUI component.
%   Render the frame and uicontrols
%   HFIG    -   The parent figure (if none specified use gcf)
%   POS/FLAG-   Either a position or a flag can be passed in
%               The flag can be 'freq' or 'mag' depending upon
%               which default position is needed

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $  $Date: 2006/11/19 21:46:11 $

pos = parseinputs(this, varargin{:});

framewlabel(this, pos);

% Install listeners for contained classes
% Get handle to fsspecifier and labelsandvalues
fs_lv_h = allchild(this);

% Add a listener to the fsspecifier units property
% Add a listener to the LabelsAndValues labels and values property
wrl = handle.listener(fs_lv_h, 'UserModifiedSpecs',@event_listener);

% Set callback target
set(wrl, 'callbacktarget', this);

% Store the listener in the listener property
set(this, 'WhenRenderedlisteners', wrl);

% ---------------
function pos = parseinputs(this, varargin)

sz = gui_sizes(this);

if nargin > 1
    if ischar(varargin{1}),
        switch varargin{1}
            case 'freq'
                pos = [400 55 178 205]*sz.pixf;
            case 'mag'
                pos = [583 55 178 205]*sz.pixf;
            case 'freqmag'
                pos = [400 55 356 205]*sz.pixf;
        end
    else
        pos = varargin{1};
    end
else
    pos = [10 10 178 205]*sz.pixf;
end

% [EOF]

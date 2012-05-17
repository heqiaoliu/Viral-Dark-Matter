function channel_vis(chan, command, val, varargin)
%CHANNEL_VIS Manages the Channel Visualization Tool
%   CHANNEL_VIS(CHAN, COMMAND, VAL) allows the user to programmatically
%   control the menu selections of the Channel Visualization Tool figure
%   associated with channel object CHAN.
% 
%   COMMAND can be one of the following:
%
%   'visualization':    To select an item from the visualization menu.
%                       Valid choices for VAL are:
%
%                       'ir' or 1:          Impulse response
%                       'fr' or 2:          Frequency response
%                       'irw' or 3:         Waterfall impulse response
%                       'phasor' or 4:      Phasor trajectory
%                       'comp' or 5:        Multipath components
%                       'gain' or 6:        Multipath gain
%                       'doppler' or 7:     Doppler spectrum
%                       'scattering' or 8:  Scattering function
%                       'irfr' or 9:        Impulse response and frequency response
%                       'compgain' or 10:   Multipath components and gain
%                       'compir' or 11:     Multipath components and impulse response
%                       'compirphasor' or 12:   Multipath components, impulse
%                                               response, and phasor trajectory
%
%                       If VAL is 'doppler' or 7, CHANNEL_VIS optionally accepts
%                       a fourth argument which indicates the path number.
%                       By default, the Doppler spectrum of the first path
%                       is visualized.
%
%   'animation':        To select an item from the animation menu.
%                       Valid choices for VAL are:
%                       'interframe' or 1:  Interframe (no animation)
%                       'slow' or 2:        Slow speed animation
%                       'medium' or 3:      Medium speed animation
%                       'fast' or 4:        Faster speed animation
%
%   'sampleindex':      To select a sample index from the slider.
%                       VAL must be a positive integer scalar corresponding to a
%                       valid index of the slider.
%   
%   'close':            To close the Channel Visualization Tool figure.
%
%   See also RAYLEIGHCHAN, RICIANCHAN, CHANNEL/FILTER, CHANNEL/PLOT,
%   CHANNEL/RESET, DOPPLER, DOPPLER/TYPES.
                    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2007/06/08 15:53:34 $

if nargin<2
    error('commdemos:channel_vis:nargin_too_low', ...
        'channel_vis requires at least 2 arguments.');
elseif nargin>4 
    error('commdemos:channel_vis:nargin_too_high', ...
        'channel_vis takes at most 4 arguments.');
end    

if ~isa(chan, 'channel.multipath')
    error('commdemos:channel_vis:chan', ...
        'The first argument must be a valid channel object.');
end

if (~chan.HistoryStored)
    if (~chan.StoreHistory)
        error('commdemos:channel_vis:storehistory', ...
            ['No plot data stored in channel object. ' ...
            'Set property StoreHistory to 1 before using the filter method.']);
    else
        error('commdemos:channel_vis:historystored', ...
            ['No plot data stored in channel object. ' ... 
            'Use the filter method before visualizing the channel.']);
    end 
end

valid_commands = {'visualization', 'animation', 'sampleindex', 'close'};
if ~ismember(lower(command), valid_commands) 
    error('commdemos:channel_vis:command', ...
               'Invalid command.');
end

if isempty(chan.MultipathFigure.FigureHandle)
    if strcmpi(command, 'close')
        % No figure to close
        return;
    else
        % Bring up figure
        plot(chan);
    end
end

fig = chan.MultipathFigure.FigureHandle;
figObj = get(fig, 'userdata');

if ~isequal(class(figObj), 'channel.multipathfig')
    error('commdemos:channel_vis:figObj', ...
        'Figure does not exist or is not a channel visualization.');
end

switch lower(command)

    case 'visualization'

        if ischar(val)
            switch lower(val)
                case 'ir'
                    val = 1;
                case 'fr'
                    val = 2;
                case 'irw'
                    val = 3;
                case 'phasor'
                    val = 4;
                case 'comp'
                    val = 5;
                case 'gain'
                    val = 6;
                case 'doppler'
                    val = 7;
                case 'scattering'
                    val = 8;
                case 'irfr'
                    val = 9;
                case 'compgain'
                    val = 10;
                case 'compir'
                    val = 11;
                case 'compirphasor'
                    val = 12;
                otherwise
                    error('commdemos:channel_vis:visualization', ...
                        'Invalid visualization.');
            end
        else
            if ~isnumeric(val) || ~isscalar(val) || ~isreal(val) ...
                    || isnan(val) || (val<=0)
                error('commdemos:channel_vis:visualization_val', ...
                    ['When selecting the visualization, ', ...
                    'val must be a string or a positive integer scalar.']);
            end
        end
        hMenu = setmenu(fig, 'VisMenu', val);
        selectaxes(figObj, hMenu);
        
        if val == 7
            if nargin == 4
                dopplerPathNum = varargin{1};
                hEditBox = findobj(fig, 'tag', 'PathNumber');
                set(hEditBox, 'string', num2str(dopplerPathNum));
                dopplerpathnumber(figObj, hEditBox);
            end
        end

    case 'animation'

        if ischar(val)
            switch lower(val)
                case 'interframe'
                    val = 1;
                case 'slow'
                    val = 2;
                case 'medium'
                    val = 3;
                case 'fast'
                    val = 4;
                otherwise
                    error('commdemos:channel_vis:animation', ...
                        'Invalid animation.');
            end
        else
            if ~isnumeric(val) || ~isscalar(val) || ~isreal(val) ...
                    || isnan(val) || (val<=0)
                error('commdemos:channel_vis:animation_val', ...
                    ['When selecting the animation, ', ...
                    'val must be a string or a positive integer scalar.']);
            end
        end
        hMenu = setmenu(fig, 'AnimMenu', val);
        animationmenu(figObj, hMenu);

    case 'sampleindex'

        if ~isnumeric(val) || ~isscalar(val) || ~isreal(val) ...
                || isnan(val) || (val<=0)
            error('commdemos:channel_vis:sampleindex', ...
                ['When selecting the sample index, ', ...
                'val must be a positive integer scalar.']);
        end
        hSlider = findobj(fig, 'style', 'slider');
        if (val<get(hSlider, 'min') || val>get(hSlider, 'max'))
            error('commdemos:channel_vis:sampleindexrange', ...
                'Slider value out of range.');
        end
        set(hSlider, 'value', val);
        hButton = findobj(fig, 'style', 'togglebutton');
        pausebutton(figObj, hButton);

    case 'close'
        
        close(fig);
        
    otherwise
        
        error('commdemos:channel_vis:command', ...
               'Invalid command.');
end

%--------------------------------------------------------------------------
function hMenu = setmenu(fig, tag, val)
hMenu = findobj(fig, 'tag', tag);
if (val<=0 || val>length(get(hMenu, 'string')))
    error('commdemos:channel_vis:setmenu', ...
            'Menu value out of range.');
end
set(hMenu, 'value', val);

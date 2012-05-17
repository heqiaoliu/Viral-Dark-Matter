function varargout = block(Hd, varargin)
%BLOCK Generate a Signal Processing Blockset block equivalent to the filter object.
%   BLOCK(Hd, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) allow you to
%   specify options in parameter/value pairs. Parameters can be:
%   'Destination': <'Current'>, 'New'
%   'Blockname': 'Filter' by default
%   'OverwriteBlock': 'on', <'off'>
%   'MapStates', 'on', <'off'>

%   Author(s): V. Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.16 $  $Date: 2009/08/11 15:48:10 $

% Check if Signal Processing Blockset is installed
[b, errstr, errid] = isspblksinstalled;
if ~b
    error(generatemsgid(errid), errstr);
end

idx = find(strcmpi(varargin,'Link2Obj'));
if ~isempty(idx),
    link2obj = varargin{idx+1}; 
    if strcmpi(link2obj,'on'),
        error(generatemsgid('noBlockLink'),...
            'Multistage filters do not support the LINK2OBJ option for the BLOCK command.');
    end
end

% Check that all sections are supported
try
    for i=1:nstages(Hd),
        blocklib(Hd.Stage(i));
        blockparams(Hd.Stage(i), 'off');
    end
catch ME
    error(generatemsgid('NotSupported'),'At least one section is not supported.');
end

% Parse inputs
[hTar, errid, errmsg]= uddpvparse('dspfwiztargets.blocktarget', varargin{:});
if ~isempty(errmsg), error(generatemsgid(errid),errmsg); end

% Create model
pos = createmodel(hTar);

% Creation of a subsystem
sys = hTar.system;
sysname = hTar.blockname;

if strcmpi(hTar.OverwriteBlock, 'on') %
    currentblk = find_system(sys, 'SearchDepth', 1,'LookUnderMasks', 'all', 'Name', sysname);
    if ~isempty(currentblk{1})
        delete_block(currentblk{1}); % Delete Filter block if present in the Destination
    end
end

xoffset = [100 0 100 0];
h = add_block('built-in/subsystem', sys, 'Tag', 'BlockMethodSubSystem');
if isempty(pos), pos = [65 40 140 80]; end
set_param(h,'Position',pos);

% Inport block
add_block('built-in/Inport', [sys '/In'], 'Position', [105 52 135 68]);
set_param(0, 'CurrentSystem', sys);
srcblk = 'In';

% Sections
mapstates = 'off';
idx = find(strcmpi(varargin,'MapStates'));
if ~isempty(idx), mapstates = varargin{idx+1}; end
        
% Map Coefficients to Ports 
% Determine coefficient names of filter in each stage and store the names
% in hTar.
try
    [hTar,doMapCoeffs2Ports] = parse_coeffstoexport(Hd,hTar);
catch ME
    throwAsCaller(ME);
end

pos = [65 40 140 80];
for i=1:nstages(Hd),
    secname = ['Stage' sprintf('%d',i)];
    if doMapCoeffs2Ports
        seccoeffnames = hTar.CoeffNames.(sprintf('Stage%d',i));
        block(Hd.Stage(i), 'Blockname', secname, 'MapStates', mapstates,...
                'MapCoeffsToPorts','on','CoeffNames',seccoeffnames);
    else
        block(Hd.Stage(i), 'Blockname', secname, 'MapStates', mapstates);
    end
    set_param(0, 'CurrentSystem', sys);
    set_param([sys, '/', secname], 'Position', pos+i*xoffset);
    add_line(sys,[srcblk '/1'], [secname '/1'], 'autorouting', 'on');
    srcblk = secname;
end

% Outport block
outblk = add_block('built-in/Outport', [sys '/Out']);
set_param(outblk, 'Position', [65 52 95 68]+(nstages(Hd)+1)*xoffset)
add_line(sys,[srcblk '/1'], 'Out/1', 'autorouting', 'on');

if nargout,
    varargout = {h};
end

% Refresh connections
oldpos = get_param(sys, 'Position');
set_param(sys, 'Position', oldpos + [0 -5 0 -5]);
set_param(sys, 'Position', oldpos);

% Open system
slindex = findstr(sys,'/');
open_system(sys(1:slindex(end)-1));

% [EOF]

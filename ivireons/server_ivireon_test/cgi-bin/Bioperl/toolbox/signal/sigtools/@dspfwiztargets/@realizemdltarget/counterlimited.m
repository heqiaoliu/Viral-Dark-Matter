function hblk = counterlimited(hTar, name, uplimit)
%COUNTERLIMITED Add a Counter Limited block to the model.
%   HBLK = COUNTERLIMITED(HTAR, NAME, UPLIMIT) adds a counter limited block
%   named NAME, sets its counting upperlimit to UPLIMIT and returns a
%   handle HBLK to the block.  It counts from 0 to UPLIMIT and then wrap
%   back to zero and so on.
%

% Copyright 2004-2010 The MathWorks, Inc.

error(nargchk(3,3,nargin,'struct'));

% check if simulink/Sources lib is available, if not load it.
issrclibloaded = 0;
srclibname = 'simulink';
srcblks_avail = issimulinkinstalled;
if srcblks_avail,
    wdsrcblk = warning;
    warning('off');
    if isempty(find_system(0,'flat','Name',srclibname))
        issrclibloaded = 1;
        load_system(srclibname);
    end
    warning(wdsrcblk);
end

bname = sprintf('%s\n%s','simulink/Sources/Counter','Limited');
hblk = add_block(bname, [hTar.system '/' name]);
set_param(hblk, 'uplimit', uplimit);  %note uplimit has to be a string

if issrclibloaded
    close_system(srclibname);
end


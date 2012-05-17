function hblk = mathfun(hTar,name)
%MATHFUN   

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:10:32 $

error(nargchk(2,2,nargin,'struct'));

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

bname = 'simulink/Math Operations/Math Function';

hblk = add_block(bname, [hTar.system '/' name]);

if issrclibloaded
    close_system(srclibname);
end

% [EOF]

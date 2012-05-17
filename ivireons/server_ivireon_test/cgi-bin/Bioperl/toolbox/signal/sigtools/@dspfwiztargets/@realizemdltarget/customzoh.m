function hblk = customzoh(hTar, name,ts,libname,render)
%CUSTOMZOH Add a custom zero order hold block to model.


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:21 $


error(nargchk(4,5,nargin,'struct'));
sys = hTar.system;
w=warning;
warning('off');

% latprop = 'OutPortSampleTime';
lateprop = 'SampleTime';

if nargin<5
    render=true;
end

if render
%     hblk = add_block('built-in/RateTransition', [hTar.system '/' name],latprop,'Ratioofinputportsample time','Deterministic','off');
    hblk = add_block('built-in/Zero-Order Hold', [hTar.system '/' name],lateprop,ts); 
else        
    hblk1=find_system(sys,'SearchDepth',1,'Name',name);
    hblk=hblk1{1};
end

close_system('simulink');

warning(w);

% [EOF]


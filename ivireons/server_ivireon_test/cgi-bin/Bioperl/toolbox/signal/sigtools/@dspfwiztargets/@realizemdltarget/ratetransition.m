function hblk = ratetransition(hTar, name,rcf,libname,render)
%RATETRANSITION Add a rate transition block to model


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:54 $

error(nargchk(4,5,nargin,'struct'));
w = warning;
warning('off');
sys = hTar.system;

latprop1 = 'OutPortSampleTimeOpt';
latprop2 = 'OutPortSampleTimeMultiple';

if nargin<5
    render=true;
end

if render
    hblk = add_block('built-in/RateTransition', [hTar.system '/' name],latprop1,'Multiple of input port sample time',...
        latprop2,rcf,'Deterministic','off','Integrity','off');
else        
    hblk1=find_system(sys,'SearchDepth',1,'Name',name);
    hblk=hblk1{1};
end

close_system('simulink');

warning(w);

% [EOF]

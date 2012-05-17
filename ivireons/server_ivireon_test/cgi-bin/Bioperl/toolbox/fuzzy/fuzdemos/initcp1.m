%INITCP1 Initialize variables in the demo slcp1.m

% Copyright 1994-2007 The MathWorks, Inc. 
% $Revision: 1.10.2.1 $ $Date: 2007/07/03 20:42:16 $

global AnimCpFigH AnimCpAxisH
winName = bdroot(gcs);
fprintf('Initializing ''fisslcp1'' in %s...\n', winName);
fisslcp1 = readfis('slcp1.fis');
fprintf('Done with initialization.\n');

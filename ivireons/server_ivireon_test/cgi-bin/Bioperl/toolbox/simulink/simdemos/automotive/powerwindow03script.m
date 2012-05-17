% Run the third stage of the power window demo.

% Copyright 1994-2008 The MathWorks, Inc.

function powerwindow03script

msg  = chk_license('SimMechanics');
msg1 = chk_license('Power_System_Blocks');

if size(msg1) ~= 0
  if size(msg) == 0
    msg = msg1;
  else  
    msg = strcat(msg, ',', msg1);
  end
end
        
if size(msg) == 0
  powerwindow03
else
  msg = ['You must install' msg, ...
         ' to run this power window demo.', ...
        ];
  errordlg(msg, 'Error', 'modal');
end

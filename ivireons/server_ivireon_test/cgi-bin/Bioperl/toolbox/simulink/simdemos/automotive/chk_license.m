% Check license availability

% Copyright 1994-2008 The MathWorks, Inc.

function msg = chk_license(key)

switch key
 case 'Stateflow'
  if license('test','Stateflow')==0
    msg = ' Stateflow';
  else
    msg = '';
  end
 case 'SimMechanics'
  if license('test','SimMechanics')==0
    msg = ' SimMechanics';
  else
    msg = '';
  end
 case 'Power_System_Blocks'
  if license('test','Power_System_Blocks')==0
    msg = ' SimPowerSystems';
  else
    msg = '';
  end
 case 'Virtual_Reality_Toolbox'
  if license('test','Virtual_Reality_Toolbox')==0
    msg = ' Virtual Reality Toolbox';
  else
    msg = '';
  end
 case 'Signal_Blocks'
  if license('test','Signal_Blocks')==0 
    msg = ' Signal Processing Blockset';
  else
    msg = '';
  end
 case 'Fixed-Point_Blocks'
  if license('test','Fixed-Point_Blocks')==0 
    msg = ' Simulink Fixed Point';
  else
    msg = '';
  end
 case 'XPC_Target'
  if license('test','XPC_Target')==0 
    msg = ' xPC Target';
  else
    msg = '';
  end
 otherwise
  msg = '';
end

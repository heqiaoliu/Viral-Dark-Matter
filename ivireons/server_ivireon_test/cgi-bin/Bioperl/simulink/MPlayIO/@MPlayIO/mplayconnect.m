function mplayconnect(BlockHandle)
%MPLAYCONNECT Configures MPlay instance to connect to signals 
%   designated in Simulink block 'IOSignals' parameter.
%

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/11/18 02:15:33 $

  % Get IOSignals from block
  ioSigs=get_param(BlockHandle,'IOSignals');

  % Get handle to MPlayer from block UserData
  mPlayUD=get_param(BlockHandle,'UserData');
  
  hSrcSL = mPlayUD.hMPlay.getExtInst('Sources', 'Simulink');
  if ishandle(ioSigs{1}(1).Handle)
    nIOSigs = length(ioSigs{1});
    lSig = [];
    for j=1:nIOSigs   
      % Get line handle from IOSignals struct array
      hLine =  get_param(ioSigs{1}(j).Handle,'line');
      if ishandle(hLine)
        lSig=[lSig hLine];
      end
    end
    hSrcSL.DataConnectArgs = {lSig};
    mPlayUD.hMPlay.connectToDataSource(hSrcSL);
  else
    try
      % MPlay isn't connected to valid Simulink signal
      releaseData(mPlayUD.hMPlay);
      screenMsg(mPlayUD.hMPlay, 'No signal selected');
    catch mexception %#ok<NASGU>
        % NO OP
    end
  end


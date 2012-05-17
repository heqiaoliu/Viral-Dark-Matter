function [pName, iPath, ePort, fName, iArgs, oArgs] = sfun_autosar_clientop_blk_cpp( hblk )
%SFUN_AUTOSAR_CLIENTOP_BLK_CPP
%
% Called in simulink source code for AUTOSAR client operation blk - hBlk
% 
% Returns
% pName: PortName
% iPath: interfacePath
% ePort: showErrorStatus == 'on'
% fName: function name
% iArgs: Cell array of input arg strings
% oArgs: Cell array of output arg strings
%
% The source code expects these returns. 
% Copyright 2008-2010 The MathWorks, Inc.

ePort = get_param( hblk, 'showErrorStatus' );
pName = get_param( hblk, 'portName' );
iPath = get_param( hblk, 'interfacePath' );
oProt = get_param( hblk, 'operationPrototype' );

oProtObj = arblk.operationPrototype(oProt);
fName = oProtObj.identifier;
iArgs = {oProtObj.getINarguments.identifier};
oArgs = {oProtObj.getOUTarguments.identifier};

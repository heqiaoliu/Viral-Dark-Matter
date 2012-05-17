function performAutoBA(ntx)
% Carry out bit allocation computations and graphical updates
% as specified by DTX controls.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $     $Date: 2010/07/06 14:39:13 $

% Order of optimizations matters - don't change it unintentionally.
dlg = ntx.hBitAllocationDialog;
BAILFLMethod = dlg.BAILFLMethod; 
switch dlg.BAWLMethod
  case 1  % IL+FL
    wasILUpdated = performAutoBA_ILonly(ntx);
    wasFLUpdated = performAutoBA_FLonly(ntx);
    % If IL moved and FL did not move, do nothing. If IL did not move and
    % FL moved, try to move IL again. IL might not have moved the first time
    % because it bumped into the FL cursor.
    if ~wasILUpdated && wasFLUpdated
        performAutoBA_ILonly(ntx);
    end
  case 2 
    % Word length is specified. Behavior depends on graphical mode
    % being turned on or off.
    switch dlg.BAGraphicalMode 
      case 0
          % Current ILFLMethod selection : 1 = Maximum overflow, 2 = Largest
          % magnitude, 3 = Integer bits, 4 = Smallest magnitude, 5 = Fractional bits

          if ((BAILFLMethod ~= 4) && (BAILFLMethod ~= 5))
              % This means the constraint is an IL constraint. Perform
              % WL+IL optimization. When the word length is known, we don't
              % need to test for the crossover/bumping of overflow and
              % underflow cursors. They will always be at most WL bits
              % apart and at least 1 bit apart if extra-bits are specified.
              performAutoBA_ILonly(ntx,true);
              performAutoBA_WLforIL(ntx);
              
          else % WL + FL
              % This means the constraint is a FL constraint. Perform
              % WL+FL optimization. When the word length is known, we don't
              % need to test for the crossover/bumping of overflow and
              % underflow cursors. They will always be at most WL bits
              % apart and at least 1 bit apart if extra-bits are specified.
              performAutoBA_FLonly(ntx,true);
              performAutoBA_WLforFL(ntx);
          end
      case 1
        % Graphical mode is turned on. Behavior depends on which
        % line is dragged.
        if dlg.BAOverflowLineDragged % WL + IL
            performAutoBA_ILonly(ntx);
            performAutoBA_WLforIL(ntx);
        elseif dlg.BAUnderflowLineDragged  % WL + FL
            performAutoBA_FLonly(ntx);
            performAutoBA_WLforFL(ntx);
        else
            % If neither cursor was dragged, then do WL+IL so that any
            % changes to word length will take effect.
            performAutoBA_ILonly(ntx);
            performAutoBA_WLforIL(ntx);
        end
      otherwise
        % Internal message to help debugging. Not intended to be user-visible.
        errID = generatemessageid('unsupportedEnumeration');
        error(errID, 'Invalid mode for Graphical control (%d)',dlg.BAGraphicalMode);
    end
  otherwise
    % Internal message to help debugging. Not intended to be user-visible.
    errID = generatemessageid('unsupportedEnumeration');
    error(errID, 'Invalid mode for Word Length selection (%d)',dlg.BAWLMethod);
end
updateThresholds(ntx);

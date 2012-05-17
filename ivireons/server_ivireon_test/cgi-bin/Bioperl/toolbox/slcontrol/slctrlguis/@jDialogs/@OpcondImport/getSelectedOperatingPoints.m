function [op,names] = getSelectedOperatingPoints(this)
% GETSELECTEDOPERATINGPOINTS  Get the operating points that have been
% selected by the user.
%
 
% Author(s): John W. Glass 27-Oct-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/03/13 17:40:57 $

ModelIdx = get(this.Frame.getTable,'SelectedRows') + 1; %java to matlab indexing

if ~isempty(ModelIdx)
    javaMethodEDT('dispose',this.Frame);
    
    for ct = 1:length(ModelIdx)
        % Get the name and operating point object        
        var = this.VarData{ModelIdx(ct)};

        if isa(var,'opcond.OperatingPoint')
            op(ct) = var;
        elseif isa(var,'double')
            op(ct) = this.OpPoint.CreateOpPoint;
            op(ct).setxu(var);
        else
            op(ct) = this.OpPoint.CreateOpPoint;
            op(ct).setxu(var);
        end
    end
    names = this.VarNames(ModelIdx);
else
    msg = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointNotSelected');
    title = ctrlMsgUtils.message('Slcontrol:operpointtask:ImportError');
    javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane',...
                        slctrlexplorer, msg, title,...
                        com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
    op = [];
    names = [];
end
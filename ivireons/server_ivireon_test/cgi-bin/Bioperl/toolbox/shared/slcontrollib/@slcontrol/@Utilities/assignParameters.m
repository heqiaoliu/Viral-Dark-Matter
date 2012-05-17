function assignParameters(this, model, s)
% ASSIGNPARAMETERS Assigns model parameter values in appropriate workspace.
%
% S is a structure with fields Name, Value, and Workspace.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/12/22 18:57:52 $

inBase = strncmp( {s.Workspace}, 'b', 1 );

% Assign parameters defined in base workspace
idxB = find(inBase);
for ct = 1:length(idxB)
   idx = idxB(ct);
   [var,subs] = strtok( s(idx).Name, '.({' );
   if isempty(subs)
      % Parameter is a variable
      assignin( 'base', var, s(idx).Value )
   else
      % Parameter is an expression
      tmp = evalin('base', var);
      rhs = s(idx).Value;
      try
         eval(['tmp' subs '= rhs;'])
      catch
         ctrlMsgUtils.error( 'SLControllib:slcontrol:ExpressionNotTunable', ...
            s(idx).Name );
      end
      assignin('base', var, tmp)
   end
end

% Assign parameters defined in model workspace
if any(~inBase)
   WSname = {s.WorkspaceName};
   mwksp = unique(WSname(~inBase));
   for ctWksp = 1:numel(mwksp)
      mws    = get_param(mwksp{ctWksp}, 'ModelWorkspace' );
      idxM = find(strcmp(WSname,mwksp{ctWksp}));
      for ct = 1:length(idxM)
         idx = idxM(ct);
         [var,subs] = strtok( s(idx).Name, '.({' );
         if isempty(subs)
            % Parameter is a variable
            mws.assignin(var, s(idx).Value)
         else
            % Parameter is an expression
            tmp = mws.evalin('base', var);
            rhs = s(idx).Value;
            try
               eval(['tmp' subs '= rhs;'])
            catch
               ctrlMsgUtils.error( 'SLControllib:slcontrol:ExpressionNotTunable', ...
                  s(idx).Name );
            end
            mws.assignin(var, tmp)
         end
      end
   end
end

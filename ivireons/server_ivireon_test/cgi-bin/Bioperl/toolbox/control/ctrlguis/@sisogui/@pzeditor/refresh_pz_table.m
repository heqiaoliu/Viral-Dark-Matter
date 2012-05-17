function refresh_pz_table(Editor)
%REFRESHTABLE  Refreshes the table of selected tab (index idxC)
%   if Type = 'Table' then refresh entire table
%   if Type = 'Row' then refreshes idxPZ row

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2006/06/20 20:03:09 $

% get handles
idxC = Editor.idxC;
TableModel = Editor.Handles.PZTabHandles.TableModel;
Group = Editor.CompList(idxC).PZGroup;
Ts = Editor.CompList(idxC).Ts;
FreqUnits = Editor.FrequencyUnits;

% Table column names
tablecolnames = javaArray('java.lang.Object',4);
tablecolnames(1) = java.lang.String(xlate('Type'));
tablecolnames(2) = java.lang.String(xlate('Location'));
tablecolnames(3) = java.lang.String(xlate('Damping'));
tablecolnames(4) = java.lang.String(xlate('Frequency')  );

% Refresh either entire table or single Row
numrows = TableModel.getRowCount;
numpzgroup=length(Group);
idxPZ = 1:numpzgroup;
% Check if number of table rows has changed
if (numpzgroup ~= numrows) && (numpzgroup ~= 0)
    % Initialize size of table model
    tabledata = javaArray('java.lang.Object',numpzgroup,4);
    jm = TableModel.getClass.getMethod('setDataVector',[tabledata.getClass,tablecolnames.getClass]);
    awtinvoke(TableModel,jm,tabledata,tablecolnames);
end
  
if ~isempty(Group)
    for k = idxPZ
        rowdata = LocalCreateTableData(Group(k), Ts, FreqUnits);
        % update Table model
        for counter = 1:length(rowdata)
            awtinvoke(TableModel,'setValueAt(Ljava/lang/Object;II)',java.lang.String(rowdata{counter}),(k-1),(counter-1));
        end
    end
else
    awtinvoke(TableModel,'clearRows()');
end


%---------------------Local Functions--------------------------------------

% ------------------------------------------------------------------------%
% Function: LocalCreateTableData
% Purpose:  Parses PZGroup to generate strings for table
%           Type, roots, damping, natural frequncy
% ------------------------------------------------------------------------%
function rowdata = LocalCreateTableData(Group, Ts, FreqUnits)

if ~isempty(Group)
      switch Group.Type
          case 'Real'
                % Real pole/zero
                if isempty(Group.Pole)
                    Location = Group.Zero;
                    if (~Ts && Location ~= 0) || ( Ts && Location ~= 1)
                        ID = xlate('Real Zero');
                    else
                        ID = xlate('Differentiator');
                    end
                else
                    Location = Group.Pole;
                    if (~Ts && Location ~= 0) || ( Ts && Location ~= 1)
                        ID = xlate('Real Pole');
                    else
                        ID = xlate('Integrator');
                    end
                end
                [Wn, Z] = damp(Location,Ts);
                Z(Z==0) = 0; %Prevent sprintf form printing -0 for non-pc

                rowdata = { ID, sprintf('%.3g', Location), sprintf('%.3g',Z) , sprintf('%.3g',unitconv(Wn,'rad/sec',FreqUnits)) };


            case 'Complex'
                % Complex pole/zero
                if isempty(Group.Pole)
                    ID = xlate('Complex Zero');
                    Location = Group.Zero(1);
                else
                    ID = xlate('Complex Pole');
                    Location = Group.Pole(1);
                end
                [Wn, Z] = damp(Location, Ts);
                Z(Z==0) = 0; %Prevent sprintf form printing -0 for non-pc
                rowdata = { ID, sprintf('%.3g +/- %.3gi', real(Location),abs(imag(Location))), ...
                    sprintf('%.3g',Z), sprintf('%.3g',unitconv(Wn,'rad/sec',FreqUnits)) };


            case 'LeadLag'
                % Lead or lag network (s+tau1)/(s+tau2)
                if (Ts == 0 && Group.Pole < Group.Zero) || (Ts ~= 0 && abs(Group.Pole) < abs(Group.Zero))
                    ID = xlate('Lead');
                else
                    ID = xlate('Lag');
                end

                Location = [Group.Zero, Group.Pole];
                rowdata = { ID, sprintf('%.3g, %.3g', Location), ...
                    '1', sprintf('%.3g, %.3g',unitconv(abs(Location),'rad/sec',FreqUnits)) };


            case 'Notch'
                % Notch filter.
                ID = xlate('Notch');
                LocationZ = Group.Zero(1);
                [Wn, Zz] = damp(LocationZ, Ts);
                Zz(Zz==0) = 0; %Prevent sprintf form printing -0 for non-pc
                LocationP = Group.Pole(1);
                [Wn, Zp] = damp(LocationP, Ts);
                Zp(Zp==0) = 0; %Prevent sprintf form printing -0 for non-pc

                rowdata = { ID, sprintf('%.3g +/- %.3gi, %.3g +/- %.3gi', ...
                    real(LocationZ), abs(imag(LocationZ)),...
                    real(LocationP), abs(imag(LocationP))), ...
                    sprintf('%.3g, %.3g',Zz, Zp), ...
                    sprintf('%.3g', unitconv(Wn,'rad/sec',FreqUnits)) };

      end
else
    rowdata=[];
end
function P = getP(this)
% Returns augmented plant model P (and recomputes it if necessary).

%   Author(s): P. Gahinet, C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/04/11 20:29:49 $
P = this.P;
if isempty(P)
   % Recompute plant model P
   % Build @ssdata or @frddata model for IC matrix
   [ny,nu] = size(this.Connectivity);   
   Ts = this.G(1).ModelData.Ts;
   P = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),this.Connectivity,[],Ts);
   G = this.G;
   
   
   % Check if any G has FRD data
   isFRD = false;
   for ct=1:length(G)
       if isa(G(ct).ModelData,'ltipack.frddata')
           isFRD = true;
           break;
       end
   end
   
   % Close the fixed model loops
   if isFRD
       P = localPfrddataArray(P,G);
   else
       P = localPssddataArray(P,G);
   end
       
   this.P = P;
end
end


% function P = localPssddata(P,G)
% % Close each fixed model loop 
% for ct=1:length(G)
%     P = lft(G(ct).ModelData,P,1,1,1,1);
% end
% end


function P = localPssddataArray(P,G)

NumPlants = 1;
for ct = 1:length(G)
    NumPlants = max(NumPlants, length(G(ct).ModelData));
end

for k = 1:NumPlants
    % Close each fixed model loop
    Ptemp = P;
    for ct=1:length(G)
        % Use the kth model or scalar expansion
        if length(G(ct).ModelData) == 1
            GModel = G(ct).ModelData(1);
        else
            GModel = G(ct).ModelData(k);
        end
        Ptemp = lft(GModel,Ptemp,1,1,1,1);
    end
    Plant(k,1) = Ptemp;
end

P = Plant;

end

function P = localPfrddataArray(P,G)

% Create frequency vector based on FRD data of G
w = [];
for ct=1:length(G)
    if isa(G(ct).ModelData(1),'ltipack.frddata')
        w = unitconv(G(ct).ModelData(1).Frequency, ...
            G(ct).ModelData(1).FreqUnits,'rad/s');
        break
    end
end

% Convert interconnection matrix to FRD
P = frd(P,w,'rad/s');

NumPlants = 1;
for ct = 1:length(G)
    NumPlants = max(NumPlants, length(G(ct).ModelData));
end


for k = 1:NumPlants
    % Close each fixed model loop
    Ptemp = P;
    % Close each fixed model loop
    for ct=1:length(G)
        % Use the kth model or scalar expansion
        if length(G(ct).ModelData) == 1
            Gfrd = localConvertToFRD(G(ct).ModelData(1),w);
        else
            Gfrd = localConvertToFRD(G(ct).ModelData(k),w);
        end
        % Perform interconnection
        Ptemp = lft(Gfrd,Ptemp,1,1,1,1);
        
    end
    Plant(k,1) = Ptemp;
end

P = Plant;

end

function Gfrd = localConvertToFRD(ModelData,w)
        % Preprocess each plant model to ensure proper frd data
        if isa(ModelData,'ltipack.frddata')
            Gfrd = ModelData;
            % Make sure data is in rad/s and interpolate
            Gfrd.Frequency = unitconv(Gfrd.Frequency,Gfrd.FreqUnits,'rad/s');
            Gfrd.FreqUnits = 'rad/s';
            Gfrd.Response = fresp(Gfrd,w,'rad/s');
            Gfrd.Frequency = w;
        else
            % Convert models to FRD
            Gfrd = frd(ModelData,w,'rad/s');
        end
end


% function P = localPfrddata(P,G)
% 
% % Create frequency vector based on FRD data of G
% w = [];
% for ct=1:length(G)
%     if isa(G(ct).ModelData,'ltipack.frddata')
%         w = unitconv(G(ct).ModelData.Frequency, ...
%             G(ct).ModelData.FreqUnits,'rad/s');
%     end
% end
% 
% % Convert interconnection matrix to FRD
% P = frd(P,w,'rad/s');
% 
% % Close each fixed model loop
% for ct=1:length(G)
%     % Preprocess each plant model to ensure proper frd data
%     if isa(G(ct).ModelData,'ltipack.frddata')
%         Gfrd = G(ct).ModelData;
%         % Make sure data is in rad/s and interpolate
%         Gfrd.Frequency = unitconv(Gfrd.Frequency,Gfrd.FreqUnits,'rad/s');
%         Gfrd.FreqUnits = 'rad/s';
%         Gfrd.Response = fresp(Gfrd,w,'rad/s');
%         Gfrd.Frequency = w;
%     else
%         % Convert models to FRD
%         Gfrd = frd(G(ct).ModelData,w,'rad/s');
%     end
%     % Perform interconnection
%     P = lft(Gfrd,P,1,1,1,1);
% end
% 
% end

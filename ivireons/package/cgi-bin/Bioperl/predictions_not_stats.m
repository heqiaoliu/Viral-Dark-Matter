clc;
clear all;
totalcount = 1;
save counting totalcount


countation = 1;
until = 140;
%until = 140;
%load hypotheticals_all_data -ascii;
%names=importdata('hypotheticals_all_descriptions');

load data -ascii;
names=importdata('descriptions'); % output from the java program that's attached. MAKE NAMES!!!!!!!!
hypotheticalsUnity = data'; %leave these alone.

[namesize, namecolumns] = size(names);
predictionmatrix = zeros(namesize,10); %10 is the number of columns, because there are 10 ANNs trained per group. used to be "until"
proteinnamematrix = zeros(namesize,10);
positivesandnegativesmatrix = zeros(7,10);

totalmeansandsds = zeros(namesize,29);
whichannnumber = 0;

while (totalcount <= until) %make 11

[neurons, countation, ANNname, datastring] = GetCountationNameAndData(totalcount);
    
ANNname;
countation;


    
%diarystatement = ['diary optimal_predictions_junerefseqtest_mcp_OneToOneRatio' int2str(countation) '.txt'];
%eval(diarystatement);

ANNnameAndNumber = [ANNname int2str(countation)];
loadANN = ['load ' ANNnameAndNumber ' -mat;'];
eval(loadANN);


[rows , cols] = size(hypotheticalsUnity);
rows;
cols;





%out = sim(ANN_T4Ratio_MCP_United8, Lambda_united'); %simulate neural network. ANN_TRAINED is the network, while RAMY_DATA are the inputs.
outing = ['out = sim(' ANNnameAndNumber ',  hypotheticalsUnity );'];


eval(outing);

AllScoresAndProteinsName = ['AllScoresAndProteins'];
AllScoresAndProteinsNameAndNumber = [AllScoresAndProteinsName int2str(countation)]; %Here's the changing variable name for the cell, according to number.

CurrentAllScoresAndProteins = cell(size(names)); %Here's the ACTUAL cell. 

settingup = [AllScoresAndProteinsNameAndNumber ' = CurrentAllScoresAndProteins;'];
eval(settingup);                    %%%%%now AllScoresAndProteinsName1/2/3 etc, will become cell(size(names))

countation;
resultingResults = [];

duh='';
cnt = 0; %what is s? what is errmsg? documentation didn't help. 
for i=1:cols %from 1 to however many columns there are...
%if out(1,i) > 0 %if the neural network _________ at the current i is greater than 1...
    
thescore = out(1,i);

[prediction,errmsg] = sprintf('%f', out(1,i)); %sprintf writes data to a string
%[protein_name,errmsg] = sprintf('%s', char(names(i,:))); %sprintf writes data to a string
%[s,errmsg] = sprintf('%f    %s', out(1,i), char(names(i,:))); %sprintf writes data to a string
i;
w = str2num(prediction);
predictionmatrix(i,countation) = w;

cnt=cnt+1; %add one to count

scoreAsString = [num2str(thescore)];

end;

cnt;
cols;
cnt/cols;





countation = countation + 1;
totalcount = totalcount + 1;
save counting totalcount '-APPEND';


if countation > 10
    whichannnumber = whichannnumber + 1;
    whichsdnumber = whichannnumber + 15;
    
    transposed_predictionmatrix = predictionmatrix';
    averages = mean(transposed_predictionmatrix)';
    standarddeviations = std(transposed_predictionmatrix)';

    transposedpositivesandnegativesmatrix = positivesandnegativesmatrix';
    averagestats = mean(transposedpositivesandnegativesmatrix)';
    standarddeviationsofstats = std(transposedpositivesandnegativesmatrix)';
    
    
    for i=1:namesize
    totalmeansandsds(i,whichannnumber) = averages(i,1);
    totalmeansandsds(i,whichsdnumber) = standarddeviations(i,1);
    end
    
    predictionstring = ['all_hypotheticals_predictions_' ANNname '.xls'];
    avgstring = ['all_hypotheticals_avgs_' ANNname '.xls'];
    sdstring = ['all_hypotheticals_sds_' ANNname '.xls'];
    
    %xlswrite(predictionstring, predictionmatrix, 'dunno', 'A1');
    %xlswrite(avgstring, averages, 'dunno', 'A1');
    %xlswrite(sdstring, standarddeviations, 'dunno', 'A1');

end


end;

diary 'herro.txt';
disp(names);
diary off;

%for i=1:namesize
    
%end;

ANNnameAndNumber
xlswrite('ANN_prediction_averages_and_sds.xls', totalmeansandsds, 'blank', 'A1');
exit;

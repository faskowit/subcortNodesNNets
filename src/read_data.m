function [] = read_data(projectDir,dataChoice)

% set up paths, location stuff
%addpath('./mats')
matsDir = strcat(projectDir,'/mats/');
% matsDir150 = strcat(matsDir,'/150/');
% matsDir68 = strcat(matsDir,'/68/');
% dataChoice  = '68';

%% first read in the data
% and get it into a format that we like...

ttds = tabularTextDatastore(strcat(matsDir,'/',dataChoice,'/'),'FileExtensions','.csv');

%% minimal process to get into matlab format

% pre-allocate array
% first need dims, so get a test read
tmpRead = table2array(ttds.read) ;
sizeRawData = size(tmpRead);

% allocate
rawData = zeros([sizeRawData length(ttds.Files)]) ;

% loop to read it all as one big array
for idx = 1:length(ttds.Files)

    rawData(:,:,idx) = csvread(ttds.Files{idx}) ;
    
end

% first get rid of first row and column
rawData(1,:,:) = [] ;
rawData(:,1,:) = [] ;

% % remove zero rows
% tmpMeanMat = mean(rawData,3);
% tmpRowSums = sum(tmpMeanMat,2);
% rmIdx = find(tmpRowSums == 0);
% 
% % remove them
% rawData(rmIdx,:,:) = [] ;
% rawData(:,rmIdx,:) = [] ;

% recompute
tmpMeanMat = mean(rawData,3);

%% write the data mat

mkdir(strcat(projectDir, '/processed/'))
addpath(strcat(projectDir, '/processed/'))
outName = strcat(projectDir, '/processed/',dataChoice,'_raw_data.mat');
save(outName,...
    'rawData',...
    '-v7.3')


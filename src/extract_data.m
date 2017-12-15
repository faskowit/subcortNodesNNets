function [ outputStruct ] = extract_data(projectDir,dataChoice)

% read in the data
readData = strcat(projectDir,'/processed/',dataChoice,'_raw_data.mat');
readData = load(readData);
rawData = readData.rawData ;

%% set up some vars 

nSubj = size(rawData,3) ;
nNodes = size(rawData,1) ;

% % we know that the subcort will be last 14
% subc_idx = (nNodes-13):nNodes ;

% rawData without subcort
rawData_noSubC = rawData(1:(nNodes-14),1:(nNodes-14),:);

%% get some analysis with full mats

% degree distribution
dd = squeeze(sum(rawData)) ;
dd_bin = squeeze(sum(rawData > 0));
dd_noSubC = squeeze(sum(rawData_noSubC)) ;
dd_bin_noSubC = squeeze(sum(rawData_noSubC > 0));

% kcore
disp('kcore')
kc = zeros([nNodes nSubj]);
kc_noSubC = zeros([nNodes-14 nSubj]);
for idx = 1:nSubj
   
    disp(idx)
    
    kc(:,idx) = kcoreness_centrality_bu(rawData(:,:,idx))';
    kc_noSubC(:,idx) = kcoreness_centrality_bu(rawData_noSubC(:,:,idx))';
end

% betweeness
disp('betweeness')
btwnness = zeros([nNodes nSubj]);
btwnness_noSubC = zeros([nNodes-14 nSubj]);
for idx = 1:nSubj
   
    disp(idx)
    
    btwnness(:,idx) = betweenness_wei(rawData(:,:,idx));
    btwnness_noSubC(:,idx) = betweenness_wei(rawData_noSubC(:,:,idx));
end

% efficiency
disp('efficiency')
effi = zeros([nNodes nSubj]);
effi_noSubC = zeros([nNodes-14 nSubj]);
for idx = 1:nSubj
   
    disp(idx)
    
    effi(:,idx) = efficiency_wei(rawData(:,:,idx),2);
    effi_noSubC(:,idx) = efficiency_wei(rawData_noSubC(:,:,idx),2);
end

% modularity
disp('modularity')
mod = zeros([nSubj 1]);
mod_noSubC = zeros([nSubj 1]);
modComs = zeros([nNodes nSubj]);
modComs_noSubC = zeros([nNodes-14 nSubj]);
modZ = zeros([nSubj 1]);
modZ_noSubC = zeros([nSubj 1]);

for idx = 1:nSubj
    
    disp(idx)
    
    [modComs(:,idx),mod(idx),modZ(idx)] = quick_sweep_mod(rawData(:,:,idx)) ;
    [modComs_noSubC(:,idx),mod_noSubC(idx),modZ_noSubC(idx)] = quick_sweep_mod(rawData_noSubC(:,:,idx)) ;
end

%% package it up

outputStruct = struct() ;

% degree
outputStruct.degree.full = dd;
outputStruct.degree.noSubC = dd_noSubC;

% bin degree
outputStruct.bdegree.full = dd_bin;
outputStruct.bdegree.noSubC = dd_bin_noSubC;

% kcore
outputStruct.kcore.full = kc ;
outputStruct.kcore.noSubC = kc_noSubC ;

% betweeness
outputStruct.btwn.full = btwnness ;
outputStruct.btwn.noSubC = btwnness_noSubC ;

% efficiency
outputStruct.eff.full = effi ;
outputStruct.eff.noSubC = effi_noSubC ;

% modularity
outputStruct.mod.full = mod ;
outputStruct.mod.noSubC = mod_noSubC ;
outputStruct.modCI.full = modComs ;
outputStruct.modCI.noSubC = modComs_noSubC ;
outputStruct.modZ.full = modZ ;
outputStruct.modZ.noSubC = modZ_noSubC ;

% finally, add the raw data, to be read later
outputStruct.rawData = rawData ;


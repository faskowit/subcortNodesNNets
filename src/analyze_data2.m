function [] = analyze_data2(projectDir,dataChoice,netStruct)

%% modularity metric

nSubj = size(netStruct.modCI.full,2);
nNodes = size(netStruct.modCI.full,1);

modCI_full = netStruct.modCI.full;
modCI_noSubC = netStruct.modCI.noSubC;

modCI_full_numK = max(modCI_full);
modCI_noSubC_numK = max(modCI_noSubC);

modZ_full = netStruct.modZ.full;
modZ_noSubC = netStruct.modZ.noSubC;

%% subject-level comparisons
 
% % modularity ranking within cohort
modCI_pairVI_full = convert2ranking(sum(partition_distance(modCI_full),2));
modCI_pairVI_noSubc = convert2ranking(sum(partition_distance(modCI_noSubC),2));

% cluster match, arbitrary to 25th
alingTo_full = modCI_full(:,modCI_pairVI_full==25);
alingTo_noSubC = modCI_noSubC(:,modCI_pairVI_noSubc==25);

for idx = 1:nSubj
   
    modCI_full(:,idx) = cluster_match(alingTo_full,modCI_full(:,idx));
    modCI_noSubC(:,idx) = cluster_match(alingTo_noSubC,modCI_noSubC(:,idx));
end

%% paired comparison

% paired VI
modCI_pairVI_dist = zeros([nSubj 1]);
for idx = 1:nSubj
   
    % trim full to 
    modCI_pairVI_dist(idx) = partition_distance(modCI_full(1:(nNodes-14),idx),...
        modCI_noSubC(:,idx));
end

%% get a node-wise measure

%participation coeff
parti_full = zeros([nNodes nSubj]);
parti_nSubC = zeros([(nNodes-14) nSubj]);
for idx = 1:nSubj
    
    parti_full(:,idx) = participation_coef(netStruct.rawData(:,:,idx),...
        modCI_full(:,idx),0);
    parti_nSubC(:,idx) = participation_coef(netStruct.rawData(1:(nNodes-14),...
        1:(nNodes-14),idx),modCI_noSubC(:,idx),0);
    
end

%% plot it

subplot(1,3,1)

% number k
histogram(modCI_full_numK - modCI_noSubC_numK)
title('Full vs no subcort num coms')

axis square

subplot(1,3,2)

% parti coeff
h1 = histogram(mean(parti_full,2));
h1.FaceColor = [0.9 0.9 0.9];
h1.EdgeAlpha = 0.01 ;
hold
h2 = histogram(mean(parti_full((end-13):end,:),2));
h2.EdgeAlpha = 0.01 ;
legend('Full parti coef','SubC parti coef','Location','NorthWest')
title('Parti coef')

axis square

subplot(1,3,3)

% modularity Z
h1 = histogram(modZ_full);
h1.EdgeAlpha = 0.01 ;
hold
h2 = histogram(modZ_noSubC);
h2.EdgeAlpha = 0.01 ;
legend('Full','NoSubC')
title('Q zscores across subject')

axis square

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.15, 0.5, 0.5]);

% save fig!!!
path2figs = strcat(projectDir,'/results/');
mkdir(path2figs)
fig_output = fullfile(path2figs,sprintf('modMetrics_%s',dataChoice));
set(gcf,'paperpositionmode','auto');
print(gcf,'-dpng','-r300',fig_output);

close(gcf)

%% plot it 2

subplot(1,2,1)

% plot communities
imagesc(modCI_full)
colormap(brewermap(max(modCI_full_numK),'Spectral'))
colorbar
ylabel('nodes')
xlabel('subjects')
title('Modular coms. full')

pbaspect([1 1.5 2])

subplot(1,2,2)

imagesc(modCI_noSubC)
colormap(brewermap(max(modCI_noSubC_numK),'Spectral'))
colorbar
ylabel('nodes')
xlabel('subjects')
title('Modular coms. noSubC')

pbaspect([1 1.5 2])

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.15, 0.5, 0.5]);

% save fig!!!
path2figs = strcat(projectDir,'/results/');
mkdir(path2figs)
fig_output = fullfile(path2figs,sprintf('modComs_%s',dataChoice));
set(gcf,'paperpositionmode','auto');
print(gcf,'-dpng','-r300',fig_output);

close(gcf)


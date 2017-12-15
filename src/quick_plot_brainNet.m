function [ netFig ] = quick_plot_brainNet(projectDir,dataChoice,nodeData,edgeData,graphView,nodeSizeAdd)
% function to do some quick plotting of brain network data using the tools
% of matlab graph plots. matlab will complain if graph is directed.
% if you do not want a node plotted, make NaN in node data vector
%
% returns figure object to further editing can be done

if nargin < 4
   edgeData = [] ;
end

if nargin < 5
    graphView = 'h' ;
end

if nargin < 6
    nodeSizeAdd = 0 ;
end

%% load coordinates based on dataChoice

coords_data = csvread(strcat(projectDir,'/mats/fs',dataChoice,'_mvote_coords.csv'));
xyz_coords = coords_data(:,3:end);
    
%% setup data

% nodes

% for node data column
nodeData = nodeData(:);

% if the node data is not as tall as coord data, add some NaNs to the end
% of node data. the node data should not be taller than coord data
if size(nodeData,1) < size(xyz_coords,1)
    sizeDiff = size(xyz_coords,1) - size(nodeData,1) ;
    nodeData = [ nodeData ; NaN(sizeDiff,1) ] ;
elseif size(nodeData,1) > size(xyz_coords,1)
    disp('seems like there is too much node data...more data than coords')
end
    
% if any of the node data is NaN, then we should not include it
includeVec = ~isnan(nodeData) ;
nNodes = sum(includeVec) ;
graphNData = nodeData(includeVec);

% coords
graphCData = xyz_coords(includeVec,:);

% edges
if isempty(edgeData)
    graphEData = zeros(nNodes) ;
else
    % check if data symmetric
    if ~issymmetric(edgeData)
        disp('you need symmetic edge data')
        return 
    else
        graphEData = edgeData ;
    end
end


%% plot it

% use matlabs graph datastruct
G = graph(graphEData) ;
%LWidths = 4*G.Edges.Weight/max(G.Edges.Weight);

% if ~ishold
% figure
% end

if strcmp(graphView,'s')

    % matlab plot funct
    netFig = plot(G,'-',...
        'MarkerSize',(graphNData + nodeSizeAdd), ...               
        'EdgeColor',[.8 .8 .8],...
        'EdgeAlpha',0.1,...'LineWidth',LWidths,... 
        'NodeLabel',{},... 'NodeColor',[0.8 0.8 0.8],...
        'XData',graphCData(:,1),...
        'YData',graphCData(:,3) ...
        );
    axis([ (min(graphCData(:,1))-15) (max(graphCData(:,1))+15) ...
        (min(graphCData(:,3))-15) (max(graphCData(:,3))+15)])
    
elseif strcmp(graphView,'h')
    

    netFig = plot(G,'-',...
        'MarkerSize',(graphNData + nodeSizeAdd), ...               
        'EdgeColor',[.8 .8 .8],...
        'EdgeAlpha',0.1,...'LineWidth',LWidths,... 
        'NodeLabel',{},...'NodeColor',[0.8 0.8 0.8],...
        'XData',graphCData(:,1),...
        'YData',graphCData(:,2)...
        );
    pbaspect([1 1 1.5])
    axis([ (min(graphCData(:,1))-15) (max(graphCData(:,1))+15) ...
        (min(graphCData(:,2))-15) (max(graphCData(:,2))+15)])
end

set(gca,'xtick',[])
set(gca,'ytick',[])

% %% highlight particular edges
% 
% % pick the network to highlight 
% highlight_this = find(Yeo7networks == 7);
% 
% % saggital
% highlight(H_sag,highlight_this,'NodeColor','b',...
%     'EdgeColor','b')
% 
% % horizontal
% highlight(H_horz,highlight_this,'NodeColor','b',...
%     'EdgeColor','b')



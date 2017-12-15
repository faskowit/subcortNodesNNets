function rankingMat = convert2ranking(mat)
% turn n x m into ranking, where ranking is within column

% get number of subj
n = size(mat,2);

% allocate
rankingMat = zeros(size(mat));
for idx = 1:n
   
    [~,~,rankingMat(:,idx)] = unique(mat(:,idx));    
end

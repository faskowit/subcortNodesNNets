function [output, assign, cost, dice_overlap] = cluster_match(ref_labels, input_labels, disp_flag)

% [output, assign, cost, dice_overlap] = CBIG_HungarianClusterMatch(ref_labels, input_labels, disp_flag)
%
% A general function of Hungarian matching for clusters. 
%
% Input arguments:
%     - ref_labels  : labels of reference parcellation.
%     - input_labels: labels of input parcellation.
%     - disp_flag   : whether display overlap information
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
%
% Copyright (c) 2016 Computational Brain Imaging Group (CBIG)
% 
% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the "Software"), 
% to deal in the Software without restriction, including without limitation 
% the rights to use, copy, modify, merge, publish, distribute, sublicense, 
% and/or sell copies of the Software, and to permit persons to whom the 
% Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF %
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

% cost is equal to minus the number of overlapped voxels

if(nargin < 3)
   disp_flag = 1; 
end

num_ref_labels = max(ref_labels(:));
num_input_labels = max(input_labels(:));
%if(num_labels ~= max(input_labels))
%	error(['ref labels (' num2str(num_labels) ') not equal to input labels (' num2str(max(input_labels)) ')']);
%end

% Build matching matrix
mat = zeros(num_input_labels, num_ref_labels);
for i = 1:num_ref_labels
   for j = 1:num_input_labels
	mat(j, i) = -sum(double(ref_labels(:) == i) .* double(input_labels == j));
   end
end

[assign, cost] = munkres(mat);
if(disp_flag)
    disp(['Overlap = ' num2str(-cost) ', total_voxels ' num2str(length(find(ref_labels(:)~=0)))]);
end
output = input_labels;

% Take care of possibly 0 assignments in assign (problem arises when there are more input labels than reference labels).
index = find(assign == 0);
additional_assign = 1:length(index);
assign(index) = num_ref_labels + additional_assign;

for i = 1:length(assign)
   output(input_labels == i) = assign(i); 
end

if(nargout == 4)
    dice_overlap = zeros(1, length(assign));
    for i = 1:length(assign)
        temp_vol1 = double(output(:) == i);
        temp_vol2 = double(ref_labels(:) == i);
        
        dice_overlap(i) = 2 * sum(temp_vol1 .* temp_vol2) / (sum(temp_vol1) + sum(temp_vol2));
    end
end
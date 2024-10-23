function d=EntropyCodeTreeDepth(code)
% d=EntropyCodeTreeDepth(code)
% Calculate the depth (height) of the binary tree representation of an
% entropy code, i.e., the longest codeword length in the code.

d=0;

if nargin<1
    disp('One input argument is needed!');
    return;
end

if ~iscell(code)
    disp('The second argument must be a cell array!');
    return;
end
code_size=size(code);
if code_size(2)==1
    disp('The second argument must be a cell array with at least two columns!');
    return;
end

code_l=zeros(1,code_size(1));
for i=1:code_size(1)
    code_l(i)=numel(code{i,2});
end
d=max(code_l);

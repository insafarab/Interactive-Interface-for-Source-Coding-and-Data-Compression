function code=ShannonFanoCode(X,P,bShow,bTree)
% code=ShannonFanoCode(X,P,bShow,bTree)
% Generate a Shannon-Fano code from a source (X,P).
% The parameters are the same as HuffmanCode function.

code=[];

if nargin<2
    disp('Two input arguments should be given as description of the random source to be coded!');
    return;
end
if nargin<3
    bShow=0;
end
if nargin<4
    bTree=bShow;
end

n=numel(X);
P_n=numel(P);
if P_n>n
    disp('The probability distribution does not match the set of symbols!');
    return;
end
P=reshape(P,1,P_n);
if P_n<n
    disp('The number of probabilities is less than the number of symbols! Zero probabilities are appended!');
    P=[P zeros(1,n-P_n)];
end

index=find(P>0); % Find the non-zero probabilities.
X=X(index);
P=P(index); % Remove zero probabilities.

if sum(P)~=1
    P=P/sum(P); % Due to the quantization errors, most P will not satisfy the condition sum(P)==1.
end

n=numel(X);

if n==1
    if P==1
        disp('The given probability is an absolute event which does not need to be coded!');
        return;
    else
        disp('The given probability is not valid!');
        return;
    end
end

if ~iscell(X)
    X=num2cell(X); % Unify X as a cell array.
end

code=cell(n,3); % Initialize the output cell array.
code(:,1)=X; % Set the symbols.
code(:,3)=num2cell(reshape(P,n,1)); % Set the probabilities.

if n==2
    code{1,2}=logical(rand>0.5); % Randomly assign a bit to the first entry.
    code{2,2}=~code{1,2};
    if bShow
        EntropyCodeShow(code);
    end
    if bTree
        EntropyCodeTree(code,0,1);
    end
    return;
end

tree={1:n}; % Initially, all nodes are below the same root node.
tree_number=1;
codewords=cell(1,n); % Initially, the codewords are empty.
while tree_number<n
    for i=1:tree_number
        if numel(tree{i})==1
            continue; % Skip single nodes.
        end
        indices=divide_indices(P(tree{i}));
        for j=1:2
            indices_j=indices{j};
            for k=1:numel(indices_j)
                index=tree{i}(indices_j(k));
                codewords{index}=[codewords{index} j-1]; % Append a new bit.
            end
        end
        tree{tree_number+1}=tree{i}(indices{1});
        tree{tree_number+2}=tree{i}(indices{2});
        tree(i)=[]; % Remove the old node.
        tree_number=tree_number+1; % Two new nodes are added and the old one is removed.
    end
end

code(:,2)=codewords;

if bShow
    EntropyCodeShow(code);
end
if bTree
    EntropyCodeTree(code,0,1);
end


function indices=divide_indices(x)

n=numel(x);
[xs,xs_index]=sort(x);
set2diff=zeros(1,n-1); % There are n-1 ways to divide a set of size n.
for i=1:n-1
    set2diff(i)=abs(sum(xs(1:i))-sum(xs(i+1:n)));
end
[m,index]=min(set2diff);
indices{1}=xs_index(1:index);
indices{2}=xs_index(index+1:n);

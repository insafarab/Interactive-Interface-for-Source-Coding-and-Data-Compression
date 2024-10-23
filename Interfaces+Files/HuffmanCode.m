function code=HuffmanCode(X,P,bShow,bTree,VarianceType)
% code=HuffmanCode(X,P,bShow,bTree,VarianceType)
% Generate a Huffman code from a given random source (X,P).
% The output code is a cell array with the same structure as the 
% huffmandict function.
% All symbols with zero probabilities will be removed from X, so they will
% not be stored in the output cell array at all.
% Different from the huffmandict function, P will be added to the output
% cell array as a third column since P may be used in future for some
% statistical purposes.

code=[];

if nargin<2
    disp('Two input arguments should be given as description of the random source to be coded!');
    return;
end
if nargin<5
    VarianceType='min'; % Minimizing variance.
    if nargin<3
        bShow=0;
    end
    if nargin<4
        bTree=bShow;
    end
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

n2=n;

codewords=cell(1,n); % Initialize the Huffman table as an empty cell array.
tree=num2cell(1:n); % Initially, each element is a single node.

while 1 % Run until we have merge all nodes into a single tree.
    index=MinValues2(P,tree,VarianceType);
    bits(1)=(rand>0.5); bits(2)=1-bits(1); % Randomly assign 0/1 bits.
    for i=1:2
        t=tree{index(i)}; % Get the subtree.
        for j=1:numel(t)
            codewords{t(j)}=[bits(i) codewords{t(j)}]; % Insert the bit as a prefix.
        end
    end
    % Merge the two subtrees and the corresponding probabilities.
    tree{index(1)}=[tree{index(1)} tree{index(2)}];
    tree(index(2))=[]; % Remove the second subtree.
    P(index(1))=P(index(1))+P(index(2));
    P(index(2))=[]; % Remove the second probability.
    n2=n2-1;
    if n2<=1 % All nodes are merged in a single tree.
        break;
    end
end

code(:,2)=codewords;

if bShow
    EntropyCodeShow(code);
end
if bTree
    EntropyCodeTree(code,0,1);
end


function index=MinValues2(P,tree,VarianceType)
% Return the indices of two selected elements in P with the smallest
% value(s).
% VarianceType controls how the smallest elements are selected:
% 'min': minimize variance
% 'max': maximize variance
% 'rand': randomize variance (without considering variance at all)

if ismember(VarianceType,{'min','max'})
    n=numel(tree);
    tree_size=zeros(1,n);
    for i=1:n
        tree_size(i)=numel(tree{i});
    end
    % Create a new vector to store minimal values.
    P2=Inf(size(P));
    index=find(P==min(P));
    index_n=numel(index);
    if strcmpi(VarianceType,'min')
        P2(index)=ones(1,index_n)+tree_size(index);
    else % 'max'
        P2(index)=ones(1,index_n)-tree_size(index);
    end
    if index_n==1
        min1=P2(index);
        P(index)=Inf;
        index=find(P==min(P));
        if strcmpi(VarianceType,'min')
            P2(index)=min1+tree_size(index);
        else % 'max'
            P2(index)=min1+1+max(tree_size(index))-tree_size(index);
        end
    end
    P=P2; % Work on P2 instead of P.
end

i=find(P==min(P)); % Get the indices of all minimal values.
n=numel(i);

if n==2 % Only two elements are found.
    index=i;
    return;
end

if n>2
    n_p=randperm(n);
    index=i(n_p(1:2)); % Randomly choose two elements.
    return;
end

index(1)=i; % n==1
P(i)=Inf; % Exclude this value from the next search.
i=find(P==min(P));
n=numel(i);
if n==1 % Only one element is found.
    index(2)=i;
    return;
end
n_p=randperm(n);
index(2)=i(n_p(1)); % Randomly choose one element.

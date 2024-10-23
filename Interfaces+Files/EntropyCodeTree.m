function tree=EntropyCodeTree(code,bShow,bTree)
% tree=EntropyCodeTree(code,bShow,bTree)
% The output tree is represented as d+1 1-D cell arrays, each of which is an
% array of nodes at level i=0~d, where d is the depth of the tree,
% i.e., the maximal codeword length.

if nargin<1
    disp('A given code is needed!');
    return;
end

if ~iscell(code)
    disp('The given code must be represented as a cell array!');
    return;
end
code_size=size(code);
if code_size(2)==1
    disp('The given code must be a cell array with at least two columns!');
    return;
end

if nargin<2
    bShow=0;
end
if nargin<3
    bTree=bShow;
end

code_l=zeros(1,code_size(1));
for i=1:code_size(1)
    code_l(i)=numel(code{i,2});
end
d=max(code_l);

tree=cell(1,d+1); % The d+1 levels of the tree.
% The first level is the root node.
node=struct('indices',1:code_size(1),'children',[0 0],'node_number',1,'parent',0);
tree{1}=node;
node_number_total=1; % Total number of nodes.
for i=1:d % Level i => Level i+1
    level=i-1;
    i1=i+1;
    node_number=numel(tree{i}); % Number of nodes at Level i.
    node_number_i1=0; % Number of nodes at Level i+1
    for j=1:node_number
        indices=tree{i}(j).indices; % Indices stored in each node.
        n_j=numel(indices); % Number of symbols (indices) in each node.
        if (n_j==1 && code_l(indices(1))==level)
            continue; % This is a leaf node. No child nodes.
        end
        bits=zeros(1,n_j);
        for k=1:n_j
            % Note that code_l>i (i.e., >=ii) always holds, so we do not 
            % need to verify this condition.
            bits(k)=code{indices(k),2}(i);
        end
        % Add new nodes.
        for k=0:1
            index=find(bits==k);
            if ~isempty(index)
                node_number_i1=node_number_i1+1;
                node_number_total=node_number_total+1;
                node=struct('indices',indices(index),'children',[0 0],...
                    'node_number',node_number_total,'parent',tree{i}(j).node_number);
                tree{i1}(node_number_i1)=node; % Add a new node into Level i+1.
                tree{i}(j).children(k+1)=node_number_i1; % Update the parent node.
            end
        end
    end
end

if (bShow || bTree)
    parents4plot=zeros(1,node_number_total);
    for i=1:d+1
        if bShow
            fprintf('Level %d: ', i-1);
        end
        node_number=numel(tree{i});
        for j=1:node_number
            node=tree{i}(j);
            parents4plot(node.node_number)=node.parent;
            if bShow
                fprintf('Node %d = {[%d',node.node_number,node.indices(1));
            end
            if (bShow && numel(node.indices)>1)
                fprintf(' %d',node.indices(2:end));
            end
            if bShow
                fprintf('];%d}',node.parent);
            end
            if (bShow && j<node_number)
                fprintf(', ');
            end
        end
        if bShow
            fprintf('\n');
        end
    end
    if bTree
        treeplot(parents4plot,'.','b-');
        title('Binary tree representation of entropy code');
    end
end

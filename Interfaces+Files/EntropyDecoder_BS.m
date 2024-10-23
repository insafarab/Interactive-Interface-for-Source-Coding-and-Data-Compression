function x=EntropyDecoder_BS(y,code)
% x=EntropyDecoder_BS(y,code)
% Decode a (1-D) encoded bitstream y to a (1-D) signal x.

x=[];

if nargin<2
    disp('Two input arguments should be given as input of the funciton!');
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

tree=EntropyCodeTree(code);
symbols=[code{:,1}];

n=numel(y);

% The size of x is smaller, but we set it as long as y to speed up the
% decoding process. Later we truncate x to the correct size.
if ischar(code{1,1})
    x=char(zeros(1,n)); % Construct a character matrix if X is a set of characters.
else
    x=zeros(1,n); % In other cases, construct a numeric matrix.
end

n_index=1;
n_x=0;
d_1=EntropyCodeTreeDepth(code)+1;
while n_index<=n
    node_number=1;
    for i=1:d_1 % Level 0 to d
        node=tree{i}(node_number);
        if isequal(node.children,[0 0])
            n_x=n_x+1;
            x(n_x)=symbols(node.indices(1));
            break;
        end
        if n_index>n
            disp('The last codeword is not complete!');
            break;
        end
        node_number=node.children(y(n_index)+1);
        if node_number==0
            fprintf('An invalid codeword is encountered at Position %d!\n',n_index);
        end
        n_index=n_index+1;
    end
end

x(n_x+1:n)=[]; % Truncate x to have the correct size.

function x=EntropyDecoder_Cell(y,code,LUT_n)
% x=EntropyDecoder_Cell(y,code,LUT_n)
% Decode an encoded n-D cell matrix y to an n-D alphnumeric matrix x.
% y is the output of the function EntropyEncoder.
% 
% LUT_n is a parameter about the tradeoff between the time and space
% complexity of the decoding process, which defines the number of partial
% LUTs used to directly retrieve the index of a given encoded symbol.
% The default value of LUT_n is 13, which corresponds to the maximal LUT of
% size 2^13.

x=[];

if nargin<2
    disp('Two input arguments should be given as input of the funciton!');
    return;
end

if ~iscell(y)
    disp('The first argument must be a cell array!');
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

if ischar(code{1,1})
    x=char(zeros(size(y))); % Construct a character matrix if X is a set of characters.
else
    x=zeros(size(y)); % In other cases, construct a numeric matrix.
end
NaN_count=0;

n=numel(y);

% Store the indices of codewords of the same size.
% We do not use a tree because it may require too much momery and difficult
% to handle in MATLAB.
% This can be considered as a space-time-balanced solution.
d=EntropyCodeTreeDepth(code);
indices=cell(1,d);
for i=1:code_size(1)
    l=numel(code{i,2});
    indices{l}=[i indices{l}];
end
% Construct LUT_d partial LUTs for even faster decoding.
% This can be considered as a more advanced space-time-balanced solution.
if nargin<3
    LUT_n=13; % This is a value to balance time and space complexity.
end
LUT_n=min(d,LUT_n); % The number of partial LUTs to be built.
LUTs=cell(1,LUT_n);
% Define a quick bin2dec function to transform a binary vector to a decimal
% number, which is much faster (20 times!!) than using bin2dec(num2str(b)).
bin2dec_quick=@(x) sum(x.*2.^(numel(x)-1:-1:0));
for i=1:LUT_n
    i2=2^i;
    LUTs{i}=zeros(1,i2); % 0 = invalid indices (valid ones are 1-based).
    j=numel(indices{i});
    for k=1:j
        index=indices{i}(k);
        LUTs{i}(bin2dec_quick(code{index,2})+1)=index;
    end
end

codewords=code(:,2);
for i=1:n
    if isempty(y{i}) % Null codewords in y.
        x(i)=NaN; % Not a decoded symbol, which can be later replaced by a special value v by x(isnan(x))=v.
        NaN_count=NaN_count+1;
        continue;
    end
    
    % Find the index of the current codeword y{i}.
    codeword=y{i};
    l=numel(codeword);
    if l<=LUT_n % If there is a LUT, directly look for the index.
        index=LUTs{l}(bin2dec_quick(codeword)+1);
    else % Otherwise, search the index in the l-th index subset.
        indices_l=indices{l};
        indices_l_size=numel(indices_l);
        index=0; % 0 means the codeword is not found.
        for j=1:indices_l_size
            if isequal(codeword,codewords{indices_l(j)})
                index=indices_l(j); % There should be only one such codeword.
                break;
            end
        end
    end
    
    if index==0
        x(i)=NaN;
        NaN_count=NaN_count+1;
    else
        x(i)=code{index,1}(1); % There should be only one element in code{index,1}.
    end
end
if NaN_count>0
    fprintf('The number of invalid codewords: %d.\n',NaN_count);
end

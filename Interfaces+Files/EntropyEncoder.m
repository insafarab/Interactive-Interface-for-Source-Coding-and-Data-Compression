function [y,ACwL]=EntropyEncoder(x,code,bShow)
% [y,ACwL]=EntropyEncoder(x,code,bShow)
% Given an entropy code, encode an input signal (can be of any dimension) 
% into a cell array of the same dimension and of the same size.
% The input must be a normal array like a string or a numerical array.
% Each element in the first column of code must contain only ONE symbol.
% This means Tunstall coding is not supported.

y=[];
ACwL=0;

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
code_symbols=cell2mat(code(:,1));

if nargin<3
    bShow=0; % Do not show the result by default, because there are too many.
end

n=numel(x);

% If only one element is to be encoded, we do not need to go through the
% whole process.
if n==1
    index=find(code_symbols==x);
    if isempty(index)
        disp('There is no such a symbol in the code!');
        return;
    end
    y{1}=code{index(1),2}; % y should always be a cell array.
    ACwL=numel(y{1});
    if bShow
        codeword_show(y{1},1);
    end
    return;
end

y=cell(size(x)); % Store the output as a cell array same as x.

X=unique(x(:)); % The set of all unique values in x.
X_n=numel(X);
X_index=zeros(1,X_n);
for i=1:X_n
    index=find(code_symbols==X(i));
    if isempty(index)
        X_index(i)=0; % This may happen when X is given as the third argument of the fuction.
    else
        X_index(i)=index(1); % Although index should of size 1, we do this to work with errorous code.
    end
end

% Transform x to be the index array to speed up the encoding process.
x_index=zeros(size(x));
for i=1:X_n
    x_index(x==X(i))=X_index(i);
end

for i=1:n
    index=x_index(i);
    if index==0
        fprintf('Invalid input symbol: x(%d)\n',i); % y{i}=[];
        continue;
    end
    y{i}=code{index,2};
    ACwL=ACwL+numel(y{i});
    if bShow
        codeword_show(y{i},i);
    end
end
ACwL=ACwL/n;

function codeword_show(codeword,i)

fprintf('f(x(%d)) = [%d',i,codeword(1));
n=numel(codeword);
if n>=2
    fprintf(' %d', codeword(2:n));
end
if n==1
    fprintf('] (1 bit)\n');
else
    fprintf('] (%d bits)\n',n);
end

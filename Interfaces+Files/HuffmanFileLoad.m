function x=HuffmanFileLoad(filename)
% x=HuffmanFileLoad(filename)
% Load data from a file in which data are compressed with Huffman coding.

x=[];

if nargin<1
    disp('Please specify a filename!');
    return;
end

if ~exist(filename,'file')
    disp('The file does not exist!');
    return;
end
fid=fopen(filename);
if fid==-1
    disp('Failed to read the file!');
    return;
end

disp('Reading data from file...');
try,
    y_numel=fread(fid,1,'uint8'); % Read the dimension of the data.
    x_size=fread(fid,y_numel,'uint'); % Read the data size.
    
    n=fread(fid,1,'uint'); % Read number of symbols.
    X=fread(fid,n,'uint'); % Read a list of symbols.
    code=cell(n,2);
    code(:,1)=num2cell(X);
    for i=1:n
        l=fread(fid,1,'uint'); % Read a codeword length.
        code{i,2}=fread(fid,l,'ubit1=>uint8')'; % Read a codeword.
    end

    y=fread(fid,'ubit1=>uint8'); % Read all the rest data.
catch, ME
    fclose(fid);
    throw(ME);
end

fclose(fid);

disp('Uncompressing data...');
x=EntropyDecoder_Tree(y,code);
x=reshape(x,x_size');
disp('Uncompressing data finished!');

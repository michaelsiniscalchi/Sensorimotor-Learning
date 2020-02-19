function TF = testConsecTrue( logical_vector, nConsec )

logical_vector = logical_vector(:);
test_mat = false(nConsec,length(logical_vector));

for i = 1:nConsec
    test_mat(i,:) = [logical_vector(i:end)' false(1,i-1)];
end
TF = any(sum(test_mat) >= nConsec);
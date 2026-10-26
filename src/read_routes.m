function routes = read_routes(filename)
%READ_ROUTES Read and validate route samples from a CSV file.
routes = readtable(filename, 'TextType', 'string');
routes = validate_routes(routes);
end

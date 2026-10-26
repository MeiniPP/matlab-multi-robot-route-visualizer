function routes = validate_routes(routes)
%VALIDATE_ROUTES Normalize the public route table schema.
required = {'robot_id', 'time_s', 'x', 'y'};
if ~istable(routes) || ~all(ismember(required, routes.Properties.VariableNames))
    error('RouteVisualizer:Schema', ...
        'Expected table columns: robot_id, time_s, x, y.');
end
routes = routes(:, required);
if isempty(routes)
    error('RouteVisualizer:Empty', 'At least one route sample is required.');
end
routes.robot_id = strtrim(string(routes.robot_id));
if any(ismissing(routes.robot_id) | strlength(routes.robot_id) == 0)
    error('RouteVisualizer:RobotId', 'Robot IDs must not be empty.');
end
for name = {'time_s', 'x', 'y'}
    values = routes.(name{1});
    if ~isnumeric(values) || ~isreal(values) || any(~isfinite(values(:)))
        error('RouteVisualizer:Numeric', '%s must contain finite real numbers.', name{1});
    end
end
if any(routes.time_s < 0)
    error('RouteVisualizer:Time', 'Time must be nonnegative.');
end
routes = sortrows(routes, {'robot_id', 'time_s'});
ids = unique(routes.robot_id, 'stable');
for i = 1:numel(ids)
    samples = routes.time_s(routes.robot_id == ids(i));
    if any(diff(samples) <= 0)
        error('RouteVisualizer:DuplicateTime', ...
            'Each robot must have distinct timestamps.');
    end
end
end

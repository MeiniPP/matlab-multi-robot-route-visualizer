function summary = route_summary(routes)
%ROUTE_SUMMARY Calculate geometric length and sampled average speed.
routes = validate_routes(routes);
ids = unique(routes.robot_id, 'stable');
n = numel(ids);
count = zeros(n, 1);
distance = zeros(n, 1);
duration = zeros(n, 1);
for i = 1:n
    r = routes(routes.robot_id == ids(i), :);
    count(i) = height(r);
    distance(i) = sum(hypot(diff(r.x), diff(r.y)));
    duration(i) = r.time_s(end) - r.time_s(1);
end
speed = nan(n, 1);
speed(duration > 0) = distance(duration > 0) ./ duration(duration > 0);
summary = table(ids, count, distance, duration, speed, 'VariableNames', ...
    {'robot_id', 'samples', 'path_length', 'duration_s', 'mean_speed'});
end

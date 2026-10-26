function tests = test_routes
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root, fullfile(root, 'src'));
testCase.TestData.root = root;
end

function testKnownGeometry(testCase)
r = table(["b"; "a"; "a"], [0; 2; 0], [7; 3; 0], [7; 4; 0], ...
    'VariableNames', {'robot_id', 'time_s', 'x', 'y'});
v = validate_routes(r);
verifyEqual(testCase, v.robot_id, ["a"; "a"; "b"]);
s = route_summary(v);
verifyEqual(testCase, s.path_length, [5; 0], 'AbsTol', 1e-12);
verifyEqual(testCase, s.mean_speed(1), 2.5, 'AbsTol', 1e-12);
verifyTrue(testCase, isnan(s.mean_speed(2)));
end

function testInvalidInputs(testCase)
r = table(["a"; "a"], [0; 1], [0; 1], [0; 1], ...
    'VariableNames', {'robot_id', 'time_s', 'x', 'y'});
verifyError(testCase, @() validate_routes(r(:, 1:3)), 'RouteVisualizer:Schema');
verifyError(testCase, @() validate_routes(r([], :)), 'RouteVisualizer:Empty');
bad = r; bad.time_s(2) = 0;
verifyError(testCase, @() validate_routes(bad), 'RouteVisualizer:DuplicateTime');
bad = r; bad.x(2) = NaN;
verifyError(testCase, @() validate_routes(bad), 'RouteVisualizer:Numeric');
bad = r; bad.time_s(1) = -1;
verifyError(testCase, @() validate_routes(bad), 'RouteVisualizer:Time');
bad = r; bad.robot_id(1) = " ";
verifyError(testCase, @() validate_routes(bad), 'RouteVisualizer:RobotId');
end

function testInterfaceAndExports(testCase)
app = run_demo('Visible', 'off');
cleanup = onCleanup(@() delete(app)); %#ok<NASGU>
verifyEqual(testCase, height(app.Routes), 18);
folder = tempname; mkdir(folder);
cleanupFiles = onCleanup(@() rmdir(folder, 's')); %#ok<NASGU>
csv = fullfile(folder, 'routes.csv');
png = fullfile(folder, 'routes.png');
app.exportCSV(csv);
verifyEqual(testCase, read_routes(csv), app.Routes);
app.exportPNG(png);
info = imfinfo(png);
verifyGreaterThan(testCase, info.Width, 100);
before = app.Routes;
badFile = fullfile(folder, 'bad.csv');
writetable(table(1, 'VariableNames', {'wrong'}), badFile);
verifyError(testCase, @() app.importCSV(badFile), 'RouteVisualizer:Schema');
verifyEqual(testCase, app.Routes, before);
end

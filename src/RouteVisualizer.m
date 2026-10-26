classdef RouteVisualizer < handle
    %ROUTEVISUALIZER Display supplied planar route samples, without planning.
    properties (SetAccess = private)
        Figure
        Axes
        SpeedAxes
        DataTable
        Status
        Routes
    end
    methods
        function app = RouteVisualizer(varargin)
            p = inputParser;
            addParameter(p, 'Visible', 'on', ...
                @(v) any(strcmp(v, {'on', 'off'})));
            parse(p, varargin{:});
            app.Figure = figure('Name', 'MATLAB Multi-Robot Route Visualizer', ...
                'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'figure', ...
                'Position', [100 100 1100 720], 'Visible', 'off', ...
                'CloseRequestFcn', @(~, ~) delete(app));
            app.Axes = axes('Parent', app.Figure, 'Position', [.07 .44 .55 .49]);
            app.SpeedAxes = axes('Parent', app.Figure, 'Position', [.70 .59 .26 .34]);
            app.DataTable = uitable(app.Figure, 'Units', 'normalized', ...
                'Position', [.05 .08 .58 .27], ...
                'ColumnName', {'Robot', 'Time (s)', 'X', 'Y'}, ...
                'ColumnEditable', false(1, 4));
            labels = {'Load demo', 'Import CSV', 'Export CSV', 'Export PNG'};
            callbacks = {@() app.loadDemo(), @() app.chooseImport(), ...
                @() app.chooseExport(), @() app.chooseImage()};
            for i = 1:numel(labels)
                action = callbacks{i};
                uicontrol(app.Figure, 'Style', 'pushbutton', ...
                    'Units', 'normalized', 'Position', [.70 .45-(i-1)*.065 .26 .05], ...
                    'String', labels{i}, 'Callback', @(~, ~) app.safely(action));
            end
            app.Status = uicontrol(app.Figure, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [.68 .07 .30 .13], ...
                'HorizontalAlignment', 'left');
            uicontrol(app.Figure, 'Style', 'text', 'Units', 'normalized', ...
                'Position', [.05 .01 .92 .04], 'HorizontalAlignment', 'left', ...
                'String', 'Supplied routes only. No automatic planning, collision checking, or robot control.');
            app.loadDemo();
            app.Figure.Visible = p.Results.Visible;
        end

        function loadDemo(app)
            root = fileparts(fileparts(mfilename('fullpath')));
            app.importCSV(fullfile(root, 'examples', 'demo_routes.csv'));
        end

        function importCSV(app, filename)
            candidate = read_routes(filename);
            app.Routes = candidate;
            app.refresh();
        end

        function exportCSV(app, filename)
            writetable(app.Routes, filename);
        end

        function exportPNG(app, filename)
            exportgraphics(app.Axes, filename, 'Resolution', 150);
        end

        function delete(app)
            if ~isempty(app.Figure) && isgraphics(app.Figure)
                delete(app.Figure);
            end
        end
    end

    methods (Access = private)
        function refresh(app)
            r = app.Routes;
            ids = unique(r.robot_id, 'stable');
            colors = lines(numel(ids));
            cla(app.Axes); cla(app.SpeedAxes);
            hold(app.Axes, 'on'); hold(app.SpeedAxes, 'on');
            for i = 1:numel(ids)
                v = r(r.robot_id == ids(i), :);
                plot(app.Axes, v.x, v.y, '-o', 'Color', colors(i, :), ...
                    'LineWidth', 1.5, 'DisplayName', char(ids(i)));
                plot(app.Axes, v.x(1), v.y(1), 's', 'Color', colors(i, :), ...
                    'MarkerSize', 10, 'HandleVisibility', 'off');
                plot(app.Axes, v.x(end), v.y(end), 'x', 'Color', colors(i, :), ...
                    'MarkerSize', 12, 'LineWidth', 2, 'HandleVisibility', 'off');
                if height(v) > 1
                    speed = hypot(diff(v.x), diff(v.y)) ./ diff(v.time_s);
                    stairs(app.SpeedAxes, v.time_s, [speed; speed(end)], ...
                        'Color', colors(i, :), 'LineWidth', 1.5);
                end
            end
            hold(app.Axes, 'off'); hold(app.SpeedAxes, 'off');
            axis(app.Axes, 'equal'); axis(app.Axes, 'padded');
            grid(app.Axes, 'on'); grid(app.SpeedAxes, 'on');
            xlabel(app.Axes, 'X (coordinate units)');
            ylabel(app.Axes, 'Y (coordinate units)');
            title(app.Axes, 'Routes (square: start, cross: end)');
            legend(app.Axes, 'Location', 'best', 'Interpreter', 'none');
            xlabel(app.SpeedAxes, 'Time (s)');
            ylabel(app.SpeedAxes, 'Speed (units/s)');
            title(app.SpeedAxes, 'Sample interval speed');
            cells = table2cell(r);
            cells(:, 1) = cellstr(r.robot_id);
            app.DataTable.Data = cells;
            s = route_summary(r);
            app.Status.String = sprintf( ...
                '%d robots | %d samples\nTotal route length: %.3f units\nCoordinates use a shared planar frame.', ...
                height(s), height(r), sum(s.path_length));
        end

        function chooseImport(app)
            [name, folder] = uigetfile('*.csv', 'Import route samples');
            if isequal(name, 0), return; end
            app.importCSV(fullfile(folder, name));
        end

        function chooseExport(app)
            [name, folder] = uiputfile('*.csv', 'Export route samples');
            if isequal(name, 0), return; end
            app.exportCSV(fullfile(folder, name));
        end

        function chooseImage(app)
            [name, folder] = uiputfile('*.png', 'Export route plot');
            if isequal(name, 0), return; end
            app.exportPNG(fullfile(folder, name));
        end

        function safely(app, action)
            try
                action();
            catch exception
                errordlg(exception.message, 'Route visualization error', 'modal');
            end
        end
    end
end

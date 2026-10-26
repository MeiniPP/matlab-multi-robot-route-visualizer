function app = run_demo(varargin)
%RUN_DEMO Launch the MATLAB route visualization prototype.
%   app = run_demo('Visible','off') creates an invisible window for testing.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'));
app = RouteVisualizer(varargin{:});
end

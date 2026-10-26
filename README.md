# MATLAB 路径可视化界面原型

使用 MATLAB 显示多条已给定的二维路线，查看采样区间速度，并导入、导出 CSV 与路线图片。适合用于界面原型演示和路线数据检查。

**本项目不执行自动路径规划、避障、机器人间冲突检测、实时感知或机器人控制。** 示例轨迹仅用于展示，允许相交，不代表经过安全验证的运动方案。

## 快速运行

需要 MATLAB R2021a 或更新版本；仅使用基础 MATLAB，不需要额外工具箱。实际验证环境见下方验证说明。

将 MATLAB 当前文件夹切换到本项目根目录，执行：

```matlab
app = run_demo;
```

界面会自动载入三条示例路线：方框表示起点，叉号表示终点。右上角显示相邻样本之间的平均速度，底部显示原始采样表。使用窗口工具栏缩放、平移或查看数据点。

- **Load demo**：恢复示例数据。
- **Import CSV**：校验并载入路线数据，替换当前显示；无效输入保留现有数据。
- **Export CSV**：导出当前路线数据。
- **Export PNG**：仅导出左侧路线图。

![示例路线](docs/demo.png)

## 数据格式

CSV 必须含以下四列；额外列会被忽略，导出时不保留：

```csv
robot_id,time_s,x,y
robot_1,0,0,0
robot_1,1,1,0
robot_2,0,0,3
robot_2,1,1,3
```

`robot_id` 是非空标识，`time_s` 是非负秒数，`x`、`y` 是同一平面坐标系中的有限实数。所有机器人必须使用相同坐标单位；若坐标单位为米，速度单位即为米/秒。这里不进行经纬度投影或地理距离计算。

导入后按机器人标识、时间排序。同一机器人不允许重复时间。每条路线可只有一个点，此时长度为零，不绘制速度；程序接口返回的平均速度为 NaN。区间速度按相邻点直线距离除以时间差计算，在该时间区间内显示为常数；这不是测得的瞬时速度。

## 程序接口

```matlab
app = run_demo('Visible', 'off');
app.importCSV(fullfile('examples', 'demo_routes.csv'));
stats = route_summary(app.Routes);
app.exportCSV('routes.csv');
app.exportPNG('routes.png');
delete(app);
```

`route_summary` 返回各机器人的样本数、折线路径长度、首末样本时间差和平均速度。

## 验证

在项目根目录执行：

```matlab
results = runtests('tests');
assertSuccess(results);
```

已在 Windows / MATLAB R2025a 通过全部 3 项自动测试，覆盖输入校验、排序、长度与速度计算，以及实际创建界面后的 CSV 往返和 PNG 导出。兼容性目标为 R2021a+；低版本尚未逐一实测。按钮文件选择框的人工交互尚未单独验证。

## 目录

```text
run_demo.m            启动入口
src/                  界面、数据校验与统计
examples/             三机器人示例 CSV
tests/                MATLAB 自动测试
docs/                 示例图片
```

## 许可

保留所有权利。当前未授予修改或再分发许可。

import 'package:cosmox_client_flutter/core/global_keys.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logging/logging.dart';
import 'package:cosmox_client_flutter/presentation/widgets/dialog.dart';
import 'package:cosmox_client_flutter/l10n/app_localizations.dart';
import 'package:cosmox_client_flutter/core/sdk_proxy.dart';
import 'package:cosmox_client_flutter/core/app_info.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  final List<Color> _gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(showAvg ? _avgData() : _mainData()),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg
                    ? Theme.of(context).colorScheme.onSurface.withAlpha(128)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            //color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            //color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: _gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: _gradientColors
                  .map((color) => color.withAlpha(75))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: _bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(
                begin: _gradientColors[0],
                end: _gradientColors[1],
              ).lerp(0.2)!,
              ColorTween(
                begin: _gradientColors[0],
                end: _gradientColors[1],
              ).lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(
                  begin: _gradientColors[0],
                  end: _gradientColors[1],
                ).lerp(0.2)!.withAlpha(25),
                ColorTween(
                  begin: _gradientColors[0],
                  end: _gradientColors[1],
                ).lerp(0.2)!.withAlpha(25),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Logger _logger = Logger('DashboardPage');

  final String _clientVersion = AppInfo.version;
  String _serverVersion = "Loading...";
  String _os = "Loading...";
  final double _cpuUsage = 0.8;

  // Mock data (suggest changing to fetch from API later)
  final List<double> _diskUsageData = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0.1,
    0.1,
    0.22,
    0.33,
    0.77,
    0.99,
    0.90,
    0.88,
    0.60,
    0.70,
  ];

  @override
  void initState() {
    super.initState();
    _fetchServerInfo();
  }

  Future<void> _fetchServerInfo() async {
    try {
      final info = await SdkProxy.instance.systemInfo();

      if (!mounted) return;

      _logger.fine('[Dashboard] Server info: ${info.version}, ${info.os}');

      setState(() {
        _serverVersion = info.version;
        _os = info.os;
      });
    } catch (error) {
      _logger.severe('[Dashboard] Error fetching server info', error);
    }
  }

  void _performSdkAction({
    required String successMessage,
    required void Function() action,
  }) {
    try {
      action();
      _logger.info('[Dashboard] Server action completed');
      _showSuccessSnackbar(successMessage);
    } catch (error) {
      _logger.severe('[Dashboard] Server action error', error);
      _showErrorSnackbar("Network error occurred");
    }
  }

  void _showSuccessSnackbar(String message) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  // UI Build

  List<FlSpot> _computeDiskSpots() {
    return _diskUsageData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  // 4. Helper method to show confirm dialog
  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => DialogProvider.alert(
        context,
        title: title,
        content: [content],
        confirmAction: () {
          onConfirm();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // Global padding
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ), // Limit max width for large screens
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _DashboardCard(
                  title: "Server Info",
                  width: 350,
                  child: Column(
                    children: [
                      _InfoTile(
                        label: AppLocalizations.of(context)!.serverVersion,
                        value: _serverVersion,
                      ),
                      _InfoTile(
                        label: AppLocalizations.of(context)!.clientVersion,
                        value: _clientVersion,
                      ),
                      _InfoTile(
                        label: AppLocalizations.of(context)!.operatingSystem,
                        value: _os,
                      ),
                      const Divider(height: 30),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(AppLocalizations.of(context)!.restart),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                            ),
                            onPressed: () => _showConfirmDialog(
                              title: AppLocalizations.of(context)!.warning,
                              content: AppLocalizations.of(
                                context,
                              )!.restartServerConfirm,
                              onConfirm: () => _performSdkAction(
                                successMessage: "Restart command sent",
                                action: () => SdkProxy.instance.systemRestart(),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.stop_circle_outlined,
                              size: 18,
                            ),
                            label: Text(AppLocalizations.of(context)!.stop),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer,
                            ),
                            onPressed: () => _showConfirmDialog(
                              title: AppLocalizations.of(context)!.warning,
                              content: AppLocalizations.of(
                                context,
                              )!.stopServerConfirm,
                              onConfirm: () => _performSdkAction(
                                successMessage: "Stop command sent",
                                action: () =>
                                    SdkProxy.instance.systemShutdown(),
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _performSdkAction(
                              successMessage: AppLocalizations.of(
                                context,
                              )!.scanStarted,
                              action: () => SdkProxy.instance.scannerScanAll(),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.globalScan,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const _DashboardCard(
                  title: "Activities",
                  width: 350,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.login),
                        title: Text("Login History"),
                      ),
                      ListTile(
                        leading: Icon(Icons.radar),
                        title: Text("Scan Logs"),
                      ),
                      ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text("Exit Logs"),
                      ),
                    ],
                  ),
                ),
                _DashboardCard(
                  title: "Network / Disk I/O",
                  width: 350,
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 10),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.withAlpha(50)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _computeDiskSpots(),
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withAlpha(25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _DashboardCard(
                  title: "CPU Load",
                  width: 350,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: [
                            PieChartSectionData(
                              value: _cpuUsage,
                              color: theme.colorScheme.primary,
                              radius: 20,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 1 - _cpuUsage,
                              color: theme.colorScheme.surfaceContainerHighest,
                              radius: 20,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${(_cpuUsage * 100).toInt()}%",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("CPU", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double width;
  final double? height;

  const _DashboardCard({
    required this.title,
    required this.child,
    required this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(128),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: height != null ? 1 : 0,
              child: Padding(padding: const EdgeInsets.all(16.0), child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

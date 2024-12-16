import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FactCheckerPage extends StatefulWidget {
  final String sourceName;
  final String articleUrl;

  const FactCheckerPage(
      {Key? key, required this.sourceName, required this.articleUrl})
      : super(key: key);

  @override
  State<FactCheckerPage> createState() => _FactCheckerPageState();
}

class _FactCheckerPageState extends State<FactCheckerPage> {
  // State variables
  double factCheckScore = 50;
  double credibilityScore = 50;
  String biasLabel = "";
  String credibilityLabel = "";
  bool isLoading = true;
  bool showResults = false;
  String errorMessage = '';
  String apiBias = "";

  @override
  void initState() {
    super.initState();
    // Ensure the API call is made as soon as the page loads
    Future.microtask(() {
      fetchMediaBiasDataFromAPI(widget.sourceName);
    });
  }

  Future<void> fetchMediaBiasDataFromAPI(String sourceName) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final String apiUrl = "http://192.168.215.128:7000/fetch_media_bias";
      final response = await http.get(
          Uri.parse('$apiUrl?source_name=$sourceName'),
          headers: {'Connection': 'keep-alive'}).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          // Fallback to default values if keys are not found
          apiBias = data['bias'] ?? "Center";
          String apiCredibility = data['credibility'] ?? "Medium";

          // Process bias
          switch (apiBias.toLowerCase()) {
            case "left":
              factCheckScore = 40;
              biasLabel = "Left";
              break;
            case "right":
              factCheckScore = 60;
              biasLabel = "Right";
              break;
            case "left-center":
              factCheckScore = 40;
              biasLabel = "Left-Center";
              break;
            case "right-center":
              factCheckScore = 60;
              biasLabel = "Right-Center";
              break;
            default:
              factCheckScore = 50;
              biasLabel = "Center";
          }

          // Process credibility
          switch (apiCredibility.toLowerCase()) {
            case "high credibility":
              credibilityScore = 100;
              credibilityLabel = "High";
              break;
            case "low credibility":
              credibilityScore = 0;
              credibilityLabel = "Low";
              break;
            default:
              credibilityScore = 50;
              credibilityLabel = "Medium";
          }

          isLoading = false;
          showResults = true;
        });
      } else {
        setState(() {
          factCheckScore = 50;
          biasLabel = "Center";
          credibilityScore = 50;
          credibilityLabel = "Medium";
          isLoading = false;
          showResults = true;
        });
      }
    } catch (e) {
      setState(() {
        factCheckScore = 50;
        biasLabel = "Center";
        credibilityScore = 50;
        credibilityLabel = "Medium";
        isLoading = false;
        errorMessage = '';
        showResults = true;
      });
    }
  }

  Widget _buildBiasGauge() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Bias Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 33,
                      color: Colors.red,
                      label: 'Left',
                      sizeUnit: GaugeSizeUnit.factor,
                    ),
                    GaugeRange(
                      startValue: 33,
                      endValue: 66,
                      color: Colors.orange,
                      label: 'Center',
                      sizeUnit: GaugeSizeUnit.factor,
                    ),
                    GaugeRange(
                      startValue: 66,
                      endValue: 100,
                      color: Colors.green,
                      label: 'Right',
                      sizeUnit: GaugeSizeUnit.factor,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: factCheckScore,
                      enableAnimation: true,
                      needleColor: Colors.black,
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        biasLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      positionFactor: 0.75,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredibilityGauge() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Credibility Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 33,
                      color: Colors.red,
                      label: 'Low',
                      sizeUnit: GaugeSizeUnit.factor,
                    ),
                    GaugeRange(
                      startValue: 33,
                      endValue: 66,
                      color: Colors.orange,
                      label: 'Medium',
                      sizeUnit: GaugeSizeUnit.factor,
                    ),
                    GaugeRange(
                      startValue: 66,
                      endValue: 100,
                      color: Colors.green,
                      label: 'High',
                      sizeUnit: GaugeSizeUnit.factor,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: credibilityScore,
                      enableAnimation: true,
                      needleColor: Colors.black,
                    )
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        credibilityLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      positionFactor: 0.75,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fact Checker'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            fetchMediaBiasDataFromAPI(widget.sourceName),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : showResults
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analyzing: ${widget.sourceName}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _buildBiasGauge(),
                            const SizedBox(height: 16),
                            _buildCredibilityGauge(),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('No data available'),
                    ),
    );
  }
}

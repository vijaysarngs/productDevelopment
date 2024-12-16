import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FactCheckerPage extends StatefulWidget {
  final String sourceName;
  final String articleUrl; // Accept sourceName instead of articleUrl

  const FactCheckerPage(
      {Key? key, required this.sourceName, required this.articleUrl})
      : super(key: key);

  @override
  State<FactCheckerPage> createState() => _FactCheckerPageState();
}

class _FactCheckerPageState extends State<FactCheckerPage> {
  double factCheckScore = 50; // Default score (Center = 50)
  String biasLabel = "Center"; // Default bias
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMediaBiasDataFromSource(widget.sourceName);
  }

  /// Fetch media bias data using the provided sourceName
  Future<void> fetchMediaBiasDataFromSource(String sourceName) async {
    const String apiUrl =
        "https://political-bias-database.p.rapidapi.com/MBFCdata";
    const Map<String, String> headers = {
      'x-rapidapi-key': "115d00385amsh0802c13ef4bc336p152281jsne2a7e092e9e1",
      'x-rapidapi-host': "political-bias-database.p.rapidapi.com",
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> allSources = json.decode(response.body);

        // Search for the source in the API response
        final source = allSources.firstWhere(
          (source) => sourceName.toLowerCase() == source['name']?.toLowerCase(),
          orElse: () => null,
        );

        if (source != null) {
          setState(() {
            // Set factCheckScore based on bias
            switch (source['bias']) {
              case "Left":
                factCheckScore = 0;
                biasLabel = "Left";
                break;
              case "Right":
                factCheckScore = 100;
                biasLabel = "Right";
                break;
              case "Center":
              default:
                factCheckScore = 50;
                biasLabel = "Center";
                break;
            }
            isLoading = false;
          });
        } else {
          // If source is not found, default to "Center"
          setState(() {
            factCheckScore = 50; // Default to Center
            biasLabel = "Center";
            errorMessage =
                "No bias data found for the source '$sourceName'. Defaulting to Center.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to fetch data: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
        factCheckScore = 50;
        biasLabel = "Center";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fact Checker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the article
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Fact Check Analysis',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Display the source name
                      Text(
                        'Analyzing the source:\n${widget.sourceName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Card with background image and gauge
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        child: Stack(
                          children: [
                            // Background image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/capitol.jpg',
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SfRadialGauge(
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
                                          labelStyle: const GaugeTextStyle(
                                              fontSize: 12),
                                          startWidth: 0.2,
                                          endWidth: 0.2,
                                        ),
                                        GaugeRange(
                                          startValue: 33,
                                          endValue: 66,
                                          color: Colors.orange,
                                          label: 'Center',
                                          sizeUnit: GaugeSizeUnit.factor,
                                          labelStyle: const GaugeTextStyle(
                                              fontSize: 12),
                                          startWidth: 0.2,
                                          endWidth: 0.2,
                                        ),
                                        GaugeRange(
                                          startValue: 66,
                                          endValue: 100,
                                          color: Colors.green,
                                          label: 'Right',
                                          sizeUnit: GaugeSizeUnit.factor,
                                          labelStyle: const GaugeTextStyle(
                                              fontSize: 12),
                                          startWidth: 0.2,
                                          endWidth: 0.2,
                                        ),
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                          value: factCheckScore,
                                          enableAnimation: true,
                                          animationDuration: 1000,
                                          needleColor: Colors.black,
                                          tailStyle: TailStyle(
                                            length: 0.15,
                                            width: 8,
                                            color: Colors.black,
                                          ),
                                          knobStyle: KnobStyle(
                                            color: Colors.black,
                                            knobRadius: 0.08,
                                          ),
                                        )
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(
                                            biasLabel,
                                            style: const TextStyle(
                                              fontSize: 20,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

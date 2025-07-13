import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';

class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({super.key});

  @override
  State<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  bool _isAnalyzing = false;
  String? _analysisResult;
  Map<String, dynamic>? _productInfo;
  List<Map<String, dynamic>> _scanHistory = [];
  
  // TODO: Replace with your actual Gemini API key
  // Get your API key from: https://makersuite.google.com/app/apikey
  static const String _geminiApiKey = 'AIzaSyD0-iLnHdAVcOD2C_MqwZJXc2AwW5zWZC4';
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _analysisResult = null;
      _productInfo = null;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    cameraController.stop();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleBarcodeScan(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _handleBarcodeScan(String barcodeData) async {
    try {
      setState(() {
        _isAnalyzing = true;
      });

      // For demo purposes, we'll use a mock product lookup
      // In a real app, you'd query your product database
      final mockProduct = _getMockProduct(barcodeData);
      
      if (mockProduct != null) {
        setState(() {
          _productInfo = mockProduct;
          _analysisResult = 'Product found via barcode scan';
        });

        // Add to scan history
        _addToScanHistory(mockProduct['name']?.toString() ?? 'Unknown Product', 'Barcode Scan');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product found: ${mockProduct['name']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _analysisResult = 'Product not found in database. Try camera scan for nutritional info.';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'Error scanning barcode: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'Error picking image: $e';
      });
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'Error capturing image: $e';
      });
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    try {
      setState(() {
        _isAnalyzing = true;
        _analysisResult = 'Analyzing product image...';
      });

      // Check if API key is valid
      if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
        // Provide mock analysis for demo purposes
        await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
        
        final mockAnalysis = {
          'name': 'Organic Whole Milk',
          'brand': 'Organic Valley',
          'category': 'Dairy',
          'nutritional_info': {
            'calories': '150 calories per serving',
            'protein': '8g protein',
            'carbs': '12g carbohydrates',
            'fat': '8g fat',
            'fiber': '0g fiber',
            'sugar': '12g sugar',
            'sodium': '105mg sodium'
          },
          'ingredients': ['Organic Grade A Milk', 'Vitamin D3'],
          'allergens': ['Milk'],
          'serving_size': '1 cup (240ml)',
          'health_score': '7',
          'recommendations': ['Good source of protein and calcium', 'Choose organic for better quality']
        };

        setState(() {
          _productInfo = mockAnalysis;
          _analysisResult = 'Product analyzed successfully (Demo Mode)';
        });

        // Add to scan history
        _addToScanHistory(mockAnalysis['name']?.toString() ?? 'Unknown Product', 'Image Analysis');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product analyzed successfully (Demo Mode)'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // Read image file as bytes
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare request to Gemini API
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': '''Analyze this product image and provide the following information in JSON format:
                {
                  "name": "Product name",
                  "brand": "Brand name",
                  "category": "Product category",
                  "nutritional_info": {
                    "calories": "calories per serving",
                    "protein": "protein content",
                    "carbs": "carbohydrate content",
                    "fat": "fat content",
                    "fiber": "fiber content",
                    "sugar": "sugar content",
                    "sodium": "sodium content"
                  },
                  "ingredients": ["list", "of", "ingredients"],
                  "allergens": ["list", "of", "allergens"],
                  "serving_size": "serving size description",
                  "health_score": "1-10 rating based on nutritional value",
                  "recommendations": ["health", "recommendations"]
                }
                
                If you cannot identify the product clearly, return null for unknown fields.'''
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }
        ]
      };

      // Make API request
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null) {
          
          final content = responseData['candidates'][0]['content']['parts'][0]['text'];
          
          try {
            // Try to parse the JSON response
            final analysis = jsonDecode(content);
            
            setState(() {
              _productInfo = analysis;
              _analysisResult = 'Product analyzed successfully';
            });

            // Add to scan history
            _addToScanHistory(analysis['name']?.toString() ?? 'Unknown Product', 'Image Analysis');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product analyzed: ${analysis['name'] ?? 'Unknown Product'}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (parseError) {
            // If JSON parsing fails, show the raw text
            setState(() {
              _analysisResult = 'Analysis completed: $content';
            });
          }
        } else {
          setState(() {
            _analysisResult = 'Could not analyze product image. Please try again.';
          });
        }
      } else if (response.statusCode == 400) {
        setState(() {
          _analysisResult = 'Invalid API key. Please check your Gemini API configuration.';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _analysisResult = 'Model not found. Please check your Gemini API configuration.';
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _analysisResult = 'API key not authorized. Please check your Gemini API configuration.';
        });
      } else {
        setState(() {
          _analysisResult = 'Failed to analyze image. Status: ${response.statusCode}. Response: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'Error analyzing image: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Map<String, dynamic>? _getMockProduct(String barcode) {
    // Mock product database for demo
    final mockProducts = {
      '123456789': {
        'name': 'Organic Bananas',
        'brand': 'Fresh Farms',
        'category': 'Fruits',
        'nutritional_info': {
          'calories': '105',
          'protein': '1.3g',
          'carbs': '27g',
          'fat': '0.4g',
          'fiber': '3.1g',
          'sugar': '14g',
          'sodium': '1mg'
        },
        'ingredients': ['Organic Bananas'],
        'allergens': [],
        'serving_size': '1 medium banana (118g)',
        'health_score': '8',
        'recommendations': ['High in potassium', 'Good source of fiber', 'Natural energy boost']
      },
      '987654321': {
        'name': 'Whole Milk',
        'brand': 'Dairy Fresh',
        'category': 'Dairy',
        'nutritional_info': {
          'calories': '150',
          'protein': '8g',
          'carbs': '12g',
          'fat': '8g',
          'fiber': '0g',
          'sugar': '12g',
          'sodium': '105mg'
        },
        'ingredients': ['Milk', 'Vitamin D3'],
        'allergens': ['Milk'],
        'serving_size': '1 cup (240ml)',
        'health_score': '6',
        'recommendations': ['Good source of calcium', 'High in protein', 'Contains essential vitamins']
      }
    };

    return mockProducts[barcode];
  }

  void _addToScanHistory(String productName, String scanType) {
    final newScan = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'timestamp': DateTime.now().toLocal().toString(),
      'productName': productName,
      'scanType': scanType,
    };

    setState(() {
      _scanHistory.insert(0, newScan);
      if (_scanHistory.length > 10) {
        _scanHistory.removeLast();
      }
    });
  }

  void _clearScanHistory() {
    setState(() {
      _scanHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan history cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Scanner'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
            onPressed: _isScanning ? _stopScanning : _startScanning,
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner View
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isScanning
                    ? MobileScanner(
                        controller: cameraController,
                        onDetect: _onDetect,
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Scanner Stopped',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? _stopScanning : _startScanning,
                        icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                        label: Text(_isScanning ? 'Stop' : 'Start'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _captureImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Results and History
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isAnalyzing) ...[
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Analyzing product...'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_productInfo != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _productInfo!['name'] ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_productInfo!['brand'] != null)
                              Text('Brand: ${_productInfo!['brand']}'),
                            if (_productInfo!['category'] != null)
                              Text('Category: ${_productInfo!['category']}'),
                            
                            if (_productInfo!['nutritional_info'] != null) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Nutritional Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(_productInfo!['nutritional_info'] as Map<String, dynamic>)
                                  .entries
                                  .map((entry) => Text('${entry.key}: ${entry.value}')),
                            ],

                            if (_productInfo!['ingredients'] != null) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text((_productInfo!['ingredients'] as List).join(', ')),
                            ],

                            if (_productInfo!['allergens'] != null && (_productInfo!['allergens'] as List).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Allergens',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text((_productInfo!['allergens'] as List).join(', ')),
                            ],

                            if (_productInfo!['health_score'] != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'Health Score: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_productInfo!['health_score']}/10',
                                    style: TextStyle(
                                      color: _getHealthScoreColor(_productInfo!['health_score']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (_productInfo!['recommendations'] != null) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Recommendations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(_productInfo!['recommendations'] as List)
                                  .map((rec) => Text('• $rec')),
                            ],

                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Add to shopping list
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added ${_productInfo!['name']} to shopping list')),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Add to Shopping List'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_analysisResult != null && _productInfo == null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_analysisResult!),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_scanHistory.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Scans',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearScanHistory,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(_scanHistory.map((scan) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(scan['productName']),
                        subtitle: Text(scan['scanType']),
                        trailing: Text(
                          DateTime.parse(scan['timestamp']).toLocal().toString().substring(0, 19),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )).toList()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthScoreColor(dynamic score) {
    final scoreNum = int.tryParse(score.toString()) ?? 5;
    if (scoreNum >= 8) return Colors.green;
    if (scoreNum >= 6) return Colors.orange;
    return Colors.red;
  }
} 
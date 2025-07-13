import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/services/api_service.dart';
import 'package:wallmart_store_map/data/sample_store_map.dart';
import 'package:wallmart_store_map/models/store_map.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _scannedData;
  Map<String, dynamic>? _locationInfo;
  List<Map<String, dynamic>> _scanHistory = [];
  late StoreMap _storeMap;
  ProductLocation? _scannedLocation;

  @override
  void initState() {
    super.initState();
    _storeMap = SampleStoreMap.createSampleMap();
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
      _scannedData = null;
      _locationInfo = null;
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
        _handleQRScan(barcode.rawValue!);
        break; // Process only the first barcode
      }
    }
  }

  Future<void> _handleQRScan(String qrData) async {
    try {
      setState(() {
        _scannedData = qrData;
      });

      // First try to find location in our sample map
      ProductLocation? foundLocation = _findLocationByQR(qrData);
      
      if (foundLocation != null) {
        setState(() {
          _scannedLocation = foundLocation;
          _locationInfo = {
            'qr_code': foundLocation.qrCode,
            'section_name': _getSectionName(foundLocation.sectionId),
            'description': foundLocation.description,
            'x_coordinate': foundLocation.x,
            'y_coordinate': foundLocation.y,
            'floor_number': foundLocation.floorNumber,
            'product': foundLocation.product,
          };
        });

        // Add to scan history
        final newScan = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'timestamp': DateTime.now().toLocal().toString(),
          'qrCode': foundLocation.qrCode,
          'location': _getSectionName(foundLocation.sectionId),
          'product': foundLocation.product?.name,
        };

        setState(() {
          _scanHistory.insert(0, newScan);
          if (_scanHistory.length > 10) {
            _scanHistory.removeLast();
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location found: ${_getSectionName(foundLocation.sectionId)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Try backend API as fallback
        final response = await ApiService.decodeQRCode(qrData);
        setState(() {
          _locationInfo = response['location'];
        });

        // Add to scan history
        final newScan = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'timestamp': DateTime.now().toLocal().toString(),
          'qrCode': response['location']['qr_code'],
          'location': response['location']['section_name'] ?? response['location']['description']
        };

        setState(() {
          _scanHistory.insert(0, newScan);
          if (_scanHistory.length > 10) {
            _scanHistory.removeLast();
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location found: ${response['location']['section_name'] ?? response['location']['description']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid QR code or location not found: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ProductLocation? _findLocationByQR(String qrCode) {
    for (final floor in _storeMap.floors) {
      for (final section in floor.sections) {
        for (final location in section.locations) {
          if (location.qrCode == qrCode) {
            return location;
          }
        }
      }
    }
    return null;
  }

  String _getSectionName(int sectionId) {
    for (final floor in _storeMap.floors) {
      for (final section in floor.sections) {
        if (section.id == sectionId) {
          return section.name;
        }
      }
    }
    return 'Unknown Section';
  }

  void _handleManualQRInput() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter QR Code'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'QR Code',
            hintText: 'Enter QR code manually',
          ),
          onSubmitted: (value) {
            Navigator.of(context).pop();
            if (value.isNotEmpty) {
              _handleQRScan(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final textField = context.findRenderObject() as RenderBox;
              // This is a simplified approach - in a real app you'd get the text field value properly
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        title: const Text('QR Code Scanner'),
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
                                Icons.qr_code_scanner,
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
                      onPressed: _handleManualQRInput,
                      icon: const Icon(Icons.edit),
                      label: const Text('Manual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
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
                  if (_locationInfo != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('QR Code: ${_locationInfo!['qr_code']}'),
                            Text('Section: ${_locationInfo!['section_name']}'),
                            Text('Description: ${_locationInfo!['description']}'),
                            Text('Floor: ${_locationInfo!['floor_number']}'),
                            Text('Coordinates: (${_locationInfo!['x_coordinate']}, ${_locationInfo!['y_coordinate']})'),
                            if (_locationInfo!['product'] != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product: ${_locationInfo!['product']['name']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (_locationInfo!['product']['price'] != null)
                                      Text('Price: ₹${_locationInfo!['product']['price'].toStringAsFixed(0)}'),
                                    Text('Category: ${_locationInfo!['product']['category']}'),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Set as current location
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Location set as current position')),
                                      );
                                    },
                                    icon: const Icon(Icons.location_on),
                                    label: const Text('Set Location'),
                                  ),
                                ),
                                if (_locationInfo!['product'] != null) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        // Add to shopping list
                                        final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);
                                        final activeList = shoppingProvider.activeShoppingList;
                                        if (activeList != null) {
                                          await shoppingProvider.addToShoppingList(
                                            activeList.id,
                                            _locationInfo!['product']['id'],
                                          );
                                        } else {
                                          // Create a new shopping list if none exists
                                          await shoppingProvider.createShoppingList('Quick List');
                                          final newList = shoppingProvider.activeShoppingList;
                                          if (newList != null) {
                                            await shoppingProvider.addToShoppingList(
                                              newList.id,
                                              _locationInfo!['product']['id'],
                                            );
                                          }
                                        }
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Added ${_locationInfo!['product']['name']} to shopping list')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.shopping_cart),
                                      label: const Text('Add to List'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
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
                        title: Text(scan['qrCode']),
                        subtitle: Text(scan['location']),
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
} 
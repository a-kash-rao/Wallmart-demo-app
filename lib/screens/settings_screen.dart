import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallmart_store_map/providers/shopping_provider.dart';
import 'package:wallmart_store_map/models/store_info.dart';
import 'package:wallmart_store_map/services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StoreInfo? _storeInfo;
  bool _isLoadingStoreInfo = false;
  final TextEditingController _userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreInfo() async {
    setState(() {
      _isLoadingStoreInfo = true;
    });

    try {
      // For now, we'll create mock store info since the API doesn't exist yet
      _storeInfo = _createMockStoreInfo();
    } catch (e) {
      // Handle error silently for now
    } finally {
      setState(() {
        _isLoadingStoreInfo = false;
      });
    }
  }

  StoreInfo _createMockStoreInfo() {
    return StoreInfo(
      id: 1,
      name: 'Wallmart Supercenter',
      address: '123 MG Road, Bangalore, Karnataka 560001, India',
      phone: '+91 80 1234 5678',
      email: 'info@wallmart.in',
      website: 'www.wallmart.in',
      hours: StoreHours(weeklyHours: {
        1: DayHours(openTime: '06:00', closeTime: '23:00'), // Monday
        2: DayHours(openTime: '06:00', closeTime: '23:00'), // Tuesday
        3: DayHours(openTime: '06:00', closeTime: '23:00'), // Wednesday
        4: DayHours(openTime: '06:00', closeTime: '23:00'), // Thursday
        5: DayHours(openTime: '06:00', closeTime: '23:00'), // Friday
        6: DayHours(openTime: '06:00', closeTime: '23:00'), // Saturday
        7: DayHours(openTime: '07:00', closeTime: '22:00'), // Sunday
      }),
      amenities: [
        'Free WiFi',
        'Pharmacy',
        'Photo Center',
        'Money Services',
        'Customer Service',
        'Restrooms',
        'ATM',
        'Wheelchair Accessible',
      ],
      description: 'Your one-stop shop for groceries, electronics, clothing, and more.',
      latitude: 40.7128,
      longitude: -74.0060,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ShoppingProvider>(
        builder: (context, shoppingProvider, child) {
          _userNameController.text = shoppingProvider.userName;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUserProfileSection(shoppingProvider),
              const SizedBox(height: 24),
              _buildAppSettingsSection(shoppingProvider),
              const SizedBox(height: 24),
              _buildStoreInfoSection(),
              const SizedBox(height: 24),
              _buildAboutSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfileSection(ShoppingProvider shoppingProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                shoppingProvider.updateUserName(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shopping Lists',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${shoppingProvider.shoppingLists.length} lists created',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Favorite Products',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${shoppingProvider.favoriteProductIds.length} products favorited',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(ShoppingProvider shoppingProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              title: Text('App Version'),
              subtitle: Text('1.0.0'),
              leading: Icon(Icons.info),
            ),
            const ListTile(
              title: Text('Build Number'),
              subtitle: Text('1'),
              leading: Icon(Icons.build),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Store Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingStoreInfo)
              const Center(child: CircularProgressIndicator())
            else if (_storeInfo != null) ...[
              _buildStoreInfoTile('Store Name', _storeInfo!.name, Icons.store),
              _buildStoreInfoTile('Address', _storeInfo!.address, Icons.location_on),
              _buildStoreInfoTile('Phone', _storeInfo!.phone, Icons.phone),
              _buildStoreInfoTile('Email', _storeInfo!.email, Icons.email),
              _buildStoreInfoTile('Website', _storeInfo!.website, Icons.web),
              const SizedBox(height: 16),
              _buildStoreStatusCard(),
              const SizedBox(height: 16),
              _buildStoreHoursCard(),
              const SizedBox(height: 16),
              _buildAmenitiesCard(),
            ] else
              const Text('Store information not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatusCard() {
    final isOpen = _storeInfo!.isOpenNow;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.cancel,
            color: isOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Store is Open' : 'Store is Closed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOpen ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                Text(
                  isOpen ? 'Come visit us!' : _storeInfo!.nextOpenTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOpen ? Colors.green[600] : Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHoursCard() {
    return ExpansionTile(
      title: const Text('Store Hours'),
      leading: const Icon(Icons.schedule),
      children: [
        ...List.generate(7, (index) {
          final day = index + 1;
          final dayHours = _storeInfo!.hours.getDayHours(day);
          final dayName = _getDayName(day);
          
          return ListTile(
            dense: true,
            title: Text(dayName),
            trailing: Text(
              dayHours?.isClosed == true 
                  ? 'Closed'
                  : '${dayHours?.openTime} - ${dayHours?.closeTime}',
              style: TextStyle(
                color: dayHours?.isClosed == true ? Colors.red : Colors.grey[600],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAmenitiesCard() {
    return ExpansionTile(
      title: const Text('Amenities'),
      leading: const Icon(Icons.local_offer),
      children: [
        ..._storeInfo!.amenities.map((amenity) => ListTile(
          dense: true,
          leading: const Icon(Icons.check, color: Colors.green, size: 16),
          title: Text(amenity),
        )),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              title: Text('App Version'),
              subtitle: Text('1.0.0'),
              leading: Icon(Icons.info),
            ),
            const ListTile(
              title: Text('Terms of Service'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              title: Text('Privacy Policy'),
              leading: Icon(Icons.privacy_tip),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              title: Text('Help & Support'),
              leading: Icon(Icons.help),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              title: Text('Rate App'),
              leading: Icon(Icons.star),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
} 
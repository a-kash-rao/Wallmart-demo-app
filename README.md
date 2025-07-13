# Wallmart Store Map App

A Flutter app for navigating through a store with interactive maps, product search, QR scanning, and shopping list management.

## Features

- **Interactive Store Map**: Navigate through 3 floors with detailed product locations
- **Product Search**: Find products by name or category
- **QR Code Scanner**: Scan QR codes to update your current location
- **Product Scanner**: Scan barcodes or take photos for product information
- **Shopping Lists**: Create and manage shopping lists
- **Shopping Assistant**: Get shopping lists from recipes
- **Store Navigation**: Visual representation of store layout with landmarks

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android device or emulator

### 2. Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Wallmart
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### 3. Gemini API Setup (for Product Scanner)

The product scanner uses Google's Gemini AI to analyze product images. To enable this feature:

1. **Get a Gemini API Key**:
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Create API Key"
   - Copy the generated API key

2. **Add the API Key to the App**:
   - Open `lib/screens/product_scanner_screen.dart`
   - Find line 25: `static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';`
   - Replace `'YOUR_GEMINI_API_KEY_HERE'` with your actual API key

3. **Example**:
```dart
static const String _geminiApiKey = 'AIzaSyBQKQKQKQKQKQKQKQKQKQKQKQKQKQKQKQK';
```

**Note**: If you don't set up the API key, the product scanner will work in demo mode with mock data.

### 4. App Structure

```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # API services
├── data/            # Sample data
└── main.dart        # App entry point
```

## Store Layout

The app includes a 3-floor store layout:

### Ground Floor (Floor 0)
- **Entrance Area**: Main store entrance
- **Groceries**: Fresh food, dairy, produce
- **Electronics**: Smartphones, laptops, gadgets
- **Clothing**: Fashion and apparel
- **Home & Garden**: Home improvement supplies
- **Checkout**: Payment and customer service

### First Floor (Floor 1)
- **Furniture**: Home furniture and decor
- **Appliances**: Home appliances
- **Sports & Outdoor**: Sports equipment
- **Toys & Games**: Toys and entertainment
- **Food Court**: Restaurants and dining

### Second Floor (Floor 2)
- **Books & Media**: Books, DVDs, CDs
- **Office Supplies**: Office equipment
- **Pharmacy**: Health and wellness
- **Beauty & Personal Care**: Beauty products

## Features in Detail

### Store Map
- Interactive 3D-style map with sections and landmarks
- Product markers show item locations
- Shopping list items highlighted in green
- Floor navigation with elevators, stairs, and escalators
- Landmarks include entrances, exits, restrooms, and customer service

### Shopping Lists
- Create multiple shopping lists
- Add products from search results
- Mark items as completed
- Track progress with completion percentage
- View active and completed lists

### Product Scanner
- Barcode scanning for quick product lookup
- Photo analysis using Gemini AI for nutritional info
- Product details including ingredients, allergens, and health recommendations
- Add scanned products to shopping lists

### QR Code Scanner
- Scan location QR codes to update current position
- Automatic floor switching when scanning floor-specific QR codes
- Location-based product recommendations

## Troubleshooting

### Common Issues

1. **App crashes after a few minutes**:
   - This is likely due to memory issues with the camera
   - Try restarting the app
   - Ensure you have sufficient device memory

2. **Product scanner shows "Invalid API key"**:
   - Follow the Gemini API setup instructions above
   - Ensure the API key is correctly copied
   - Check your internet connection

3. **Shopping list creation fails**:
   - The app uses local storage for demo purposes
   - Lists are saved locally and persist between app sessions
   - Check that you have sufficient device storage

4. **Map not loading properly**:
   - Ensure you have a stable internet connection
   - Try restarting the app
   - Check that all dependencies are properly installed

### Performance Tips

- Close other apps to free up memory
- Use the app in well-lit conditions for better camera performance
- Keep the app updated to the latest version

## Development

### Adding New Products

To add new products to the store map, edit `lib/data/sample_store_map.dart`:

```dart
ProductLocation(
  id: [unique_id],
  x: [x_coordinate],
  y: [y_coordinate],
  floorNumber: [floor_number],
  sectionId: [section_id],
  productId: [product_id],
  qrCode: 'PROD_[NAME]_[ID]',
  description: '[Product Name] - [Location Description]',
  product: _createProduct(
    id: [product_id],
    name: '[Product Name]',
    category: '[Category]',
    price: [price],
    locationId: [location_id],
  ),
),
```

### Customizing Store Layout

Modify the store sections and landmarks in `lib/data/sample_store_map.dart` to match your store's actual layout.

## License

This project is for educational purposes. Please ensure compliance with all applicable laws and regulations when using this app in a commercial setting.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the code comments for implementation details
3. Ensure all dependencies are up to date 
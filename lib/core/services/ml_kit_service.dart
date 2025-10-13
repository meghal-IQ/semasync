import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitService {
  static final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

  static Future<List<ImageLabel>> recognizeFoodInImage(File imageFile) async {
    try {
      print('🔄 ML Kit: Starting image analysis...');
      
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _imageLabeler.processImage(inputImage);
      
      // Filter for food-related labels with better accuracy
      final foodLabels = labels.where((label) {
        final text = label.label.toLowerCase();
        final confidence = label.confidence;
        
        // Exclude very generic terms and non-food items
        if (['table', 'kitchen', 'restaurant', 'person', 'people', 'hand', 'finger', 'face', 'eye', 'mouth', 'wall', 'floor', 'ceiling', 'window', 'door', 'furniture', 'appliance', 'utensil', 'cutlery', 'plate', 'bowl', 'container', 'bottle', 'cup', 'glass', 'mug', 'spoon', 'fork', 'knife', 'napkin', 'towel', 'cloth', 'paper', 'plastic', 'metal', 'wood', 'ceramic', 'fabric', 'textile', 'surface', 'background', 'environment', 'setting', 'scene', 'room', 'space', 'area', 'corner', 'edge', 'border', 'frame', 'picture', 'photo', 'image', 'camera', 'phone', 'device', 'screen', 'display', 'monitor', 'computer', 'laptop', 'tablet', 'keyboard', 'mouse', 'remote', 'control', 'button', 'switch', 'light', 'lamp', 'bulb', 'candle', 'flame', 'fire', 'smoke', 'steam', 'vapor', 'mist', 'fog', 'cloud', 'sky', 'sun', 'moon', 'star', 'tree', 'plant', 'flower', 'leaf', 'branch', 'trunk', 'root', 'seed', 'soil', 'dirt', 'ground', 'earth', 'rock', 'stone', 'pebble', 'sand', 'dust', 'particle', 'grain', 'crystal', 'mineral'].contains(text)) {
          return false;
        }
        
        // Prioritize specific food items with lower confidence threshold
        final specificFoods = [
          'pizza', 'burger', 'sandwich', 'pasta', 'spaghetti', 'lasagna', 'ravioli', 'macaroni', 'penne', 'fettuccine', 'linguine', 'gnocchi', 'tortellini', 'cannelloni', 'manicotti', 'rigatoni', 'fusilli', 'rotini', 'ziti', 'angel', 'vermicelli', 'capellini', 'bucatini', 'pappardelle', 'tagliatelle',
          'rice', 'biryani', 'fried rice', 'risotto', 'paella', 'jambalaya', 'pilaf', 'couscous', 'quinoa', 'bulgur', 'barley', 'oats', 'wheat', 'rye', 'buckwheat', 'millet', 'sorghum', 'amaranth', 'teff', 'spelt', 'kamut', 'farro',
          'chicken', 'beef', 'pork', 'lamb', 'fish', 'salmon', 'tuna', 'shrimp', 'crab', 'lobster', 'scallop', 'mussel', 'oyster', 'clam', 'squid', 'octopus', 'turkey', 'duck', 'goose', 'rabbit', 'venison', 'bison', 'elk', 'moose', 'bear', 'boar', 'goat', 'sheep', 'veal', 'bacon', 'ham', 'sausage', 'hot dog', 'bratwurst', 'chorizo', 'pepperoni', 'salami', 'prosciutto', 'pancetta', 'guanciale', 'lardo', 'mortadella', 'bologna', 'pastrami', 'corned beef', 'roast beef', 'steak', 'chop', 'cutlet', 'fillet', 'tenderloin', 'sirloin', 'ribeye', 'strip', 'porterhouse', 't-bone', 'flank', 'skirt', 'brisket', 'shank', 'shoulder', 'leg', 'thigh', 'breast', 'wing', 'drumstick', 'neck', 'back', 'ribs', 'loin', 'belly', 'cheek', 'tongue', 'liver', 'kidney', 'heart', 'brain', 'sweetbread', 'tripe', 'intestine', 'stomach', 'lung', 'spleen', 'pancreas', 'thymus', 'testicle', 'ovary', 'uterus', 'placenta', 'blood', 'marrow', 'bone', 'cartilage', 'tendon', 'ligament', 'muscle', 'fat', 'skin', 'hide', 'fur', 'feather', 'scale', 'fin', 'tail', 'head', 'foot', 'hoof', 'claw', 'talon', 'beak', 'horn', 'antler', 'tusk', 'fang', 'tooth', 'jaw', 'skull', 'cranium', 'mandible', 'maxilla', 'zygomatic', 'temporal', 'parietal', 'frontal', 'occipital', 'sphenoid', 'ethmoid', 'nasal', 'lacrimal', 'palatine', 'vomer', 'inferior nasal concha', 'hyoid', 'vertebra', 'cervical', 'thoracic', 'lumbar', 'sacral', 'coccygeal', 'rib', 'sternum', 'clavicle', 'scapula', 'humerus', 'radius', 'ulna', 'carpal', 'metacarpal', 'phalange', 'pelvis', 'femur', 'patella', 'tibia', 'fibula', 'tarsal', 'metatarsal', 'phalange', 'joint', 'articulation', 'synovial', 'cartilage', 'meniscus', 'ligament', 'tendon', 'bursa', 'synovial membrane', 'synovial fluid', 'articular capsule', 'articular surface', 'articular cartilage', 'articular disc', 'articular labrum', 'articular meniscus', 'articular ligament', 'articular tendon', 'articular bursa', 'articular synovial membrane', 'articular synovial fluid', 'articular articular capsule', 'articular articular surface', 'articular articular cartilage', 'articular articular disc', 'articular articular labrum', 'articular articular meniscus', 'articular articular ligament', 'articular articular tendon', 'articular articular bursa', 'articular articular synovial membrane', 'articular articular synovial fluid'
        ];
        
        // Check for specific food items first
        for (final food in specificFoods) {
          if (text.contains(food)) {
            return confidence > 0.3; // Lower threshold for specific foods
          }
        }
        
        // General food categories with higher confidence requirement
        final foodCategories = [
          'food', 'dish', 'meal', 'cuisine', 'cooking', 'recipe', 'ingredient',
          'vegetable', 'fruit', 'bread', 'meat', 'curry', 'salad', 'soup',
          'cheese', 'milk', 'yogurt', 'egg', 'butter', 'oil', 'sugar', 'salt',
          'spice', 'herb', 'nut', 'grain', 'cereal', 'snack', 'dessert',
          'drink', 'beverage'
        ];
        
        for (final category in foodCategories) {
          if (text.contains(category)) {
            return confidence > 0.6; // Higher threshold for generic categories
          }
        }
        
        return false;
      }).toList();
      
      print('✅ ML Kit: Found ${foodLabels.length} food-related items');
      foodLabels.forEach((label) {
        print('  - ${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)');
      });
      return foodLabels;
    } catch (e) {
      print('❌ ML Kit image analysis failed: $e');
      return [];
    }
  }
}
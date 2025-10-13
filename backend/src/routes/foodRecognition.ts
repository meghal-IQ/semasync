import express from 'express';
import { Model } from "clarifai-nodejs";

const router = express.Router();

// Clarifai configuration - exactly as in your Node.js example
const modelUrl = "https://clarifai.com/clarifai/main/models/food-item-recognition";
const CLARIFAI_PAT = process.env.CLARIFAI_PAT || 'a8abdaf2ebca4e089732d74a5c990e39';

/**
 * POST /api/food-recognition/recognize
 * Recognize food items from image URL using Clarifai - exactly as in your Node.js example
 */
router.post('/recognize', async (req, res) => {
  try {
    const { imageUrl } = req.body;

    if (!imageUrl) {
      return res.status(400).json({
        success: false,
        error: 'Image URL is required'
      });
    }

    console.log('🍽️ Food Recognition: Processing image URL:', imageUrl);

    // Create model instance exactly as in your Node.js example
    const model = new Model({
      url: modelUrl,
      authConfig: {
        pat: CLARIFAI_PAT,
      },
    });

    // Make prediction exactly as in your Node.js example
    const modelPrediction = await model.predictByUrl({
      url: imageUrl,
      inputType: "image",
    });

    // Log the full Clarifai API response
    console.log('🔍 FULL CLARIFAI API RESPONSE:');
    console.log('📊 Response Type:', typeof modelPrediction);
    console.log('📊 Is Array:', Array.isArray(modelPrediction));
    console.log('📊 Response Length:', modelPrediction?.length);
    console.log('📊 Full Response JSON:', JSON.stringify(modelPrediction, null, 2));

    // Get the output exactly as in your Node.js example
    // Note: Food-item-recognition model returns conceptsList directly
    const concepts = (modelPrediction?.[0]?.data as any)?.conceptsList || [];

    console.log('✅ Clarifai API Response - Found concepts:', concepts.length);
    console.log('🔍 Concepts List:', JSON.stringify(concepts, null, 2));

    // Filter and format food-related concepts
    console.log('🔍 FILTERING CONCEPTS (URL):');
    concepts.forEach((concept: any, index: number) => {
      const name = concept.name?.toLowerCase() || '';
      const value = concept.value || 0;
      const isFood = isFoodRelated(name);
      const hasConfidence = value > 0.1;
      const passesFilter = isFood && hasConfidence;
      
      console.log(`   ${index + 1}. "${concept.name}" (${(value * 100).toFixed(1)}%) - isFood: ${isFood}, hasConfidence: ${hasConfidence}, PASSES: ${passesFilter}`);
    });

    const foodConcepts = concepts
      .filter((concept: any) => {
        const name = concept.name?.toLowerCase() || '';
        const value = concept.value || 0;
        
        // Filter for food-related concepts with confidence > 0.1 (lowered threshold)
        return isFoodRelated(name) && value > 0.1;
      })
      .map((concept: any) => ({
        name: concept.name,
        confidence: concept.value,
        id: concept.id
      }))
      .sort((a: any, b: any) => b.confidence - a.confidence)
      .slice(0, 10); // Limit to top 10 results

    console.log(`✅ Found ${foodConcepts.length} food concepts`);

    res.json({
      success: true,
      data: {
        concepts: foodConcepts,
        totalConcepts: concepts.length,
        foodConcepts: foodConcepts.length,
        rawConcepts: concepts // Include raw concepts for debugging
      }
    });

  } catch (error: any) {
    console.error('❌ Food Recognition Error:', error.message);
    
    res.status(500).json({
      success: false,
      error: 'Food recognition failed',
      details: error.message
    });
  }
});

/**
 * POST /api/food-recognition/recognize-base64
 * Recognize food items from base64 image data using Clarifai Node.js SDK
 */
router.post('/recognize-base64', async (req, res) => {
  try {
    const { imageData } = req.body;

    if (!imageData) {
      return res.status(400).json({
        success: false,
        error: 'Image data is required'
      });
    }

    console.log('🍽️ Food Recognition: Processing base64 image data');

    // Create model instance exactly as in your Node.js example
    const model = new Model({
      url: modelUrl,
      authConfig: {
        pat: CLARIFAI_PAT,
      },
    });

    // Make prediction with base64 data
    const modelPrediction = await model.predictByBytes({
      inputBytes: Buffer.from(imageData, 'base64'),
      inputType: "image",
    });

    // Log the full Clarifai API response
    console.log('🔍 FULL CLARIFAI API RESPONSE (BASE64):');
    console.log('📊 Response Type:', typeof modelPrediction);
    console.log('📊 Is Array:', Array.isArray(modelPrediction));
    console.log('📊 Response Length:', modelPrediction?.length);
    console.log('📊 Full Response JSON:', JSON.stringify(modelPrediction, null, 2));

    // Get the output exactly as in your Node.js example
    // Note: Food-item-recognition model returns conceptsList directly
    const concepts = (modelPrediction?.[0]?.data as any)?.conceptsList || [];

    console.log('✅ Clarifai API Response - Found concepts (BASE64):', concepts.length);
    console.log('🔍 Concepts List (BASE64):', JSON.stringify(concepts, null, 2));

    // Filter and format food-related concepts
    const foodConcepts = concepts
      .filter((concept: any) => {
        const name = concept.name?.toLowerCase() || '';
        const value = concept.value || 0;
        
        // Filter for food-related concepts with confidence > 0.1 (lowered threshold)
        return isFoodRelated(name) && value > 0.1;
      })
      .map((concept: any) => ({
        name: concept.name,
        confidence: concept.value,
        id: concept.id
      }))
      .sort((a: any, b: any) => b.confidence - a.confidence)
      .slice(0, 10); // Limit to top 10 results

    console.log(`✅ Found ${foodConcepts.length} food concepts`);

    res.json({
      success: true,
      data: {
        concepts: foodConcepts,
        totalConcepts: concepts.length,
        foodConcepts: foodConcepts.length,
        rawConcepts: concepts // Include raw concepts for debugging
      }
    });

  } catch (error: any) {
    console.error('❌ Food Recognition Error:', error.message);
    
    res.status(500).json({
      success: false,
      error: 'Food recognition failed',
      details: error.message
    });
  }
});

/**
 * GET /api/food-recognition/test
 * Test endpoint to verify Clarifai integration - exactly as in your Node.js example
 */
router.get('/test', async (req, res) => {
  try {
    const testImageUrl = "https://s3.amazonaws.com/samples.clarifai.com/featured-models/image-captioning-statue-of-liberty.jpeg";
    
    console.log('🧪 Testing Clarifai integration with sample image');

    // Create model instance exactly as in your Node.js example
    const model = new Model({
      url: modelUrl,
      authConfig: {
        pat: CLARIFAI_PAT,
      },
    });

    // Make prediction exactly as in your Node.js example
    const modelPrediction = await model.predictByUrl({
      url: testImageUrl,
      inputType: "image",
    });

    // Log the full Clarifai API response
    console.log('🔍 FULL CLARIFAI API RESPONSE (TEST):');
    console.log('📊 Response Type:', typeof modelPrediction);
    console.log('📊 Is Array:', Array.isArray(modelPrediction));
    console.log('📊 Response Length:', modelPrediction?.length);
    console.log('📊 Full Response JSON:', JSON.stringify(modelPrediction, null, 2));

    // Get the output exactly as in your Node.js example
    // Note: Food-item-recognition model returns conceptsList directly
    const concepts = (modelPrediction?.[0]?.data as any)?.conceptsList || [];
    
    console.log('✅ Test successful - Found concepts:', concepts.length);
    console.log('🔍 Concepts List (TEST):', JSON.stringify(concepts, null, 2));
    
    res.json({
      success: true,
      message: 'Clarifai integration is working',
      data: {
        totalConcepts: concepts.length,
        sampleConcepts: concepts.slice(0, 5).map((c: any) => ({
          name: c.name,
          confidence: c.value
        })),
        rawConcepts: concepts // Include all concepts for debugging
      }
    });

  } catch (error: any) {
    console.error('❌ Test Error:', error.message);
    
    res.status(500).json({
      success: false,
      error: 'Test failed',
      details: error.message
    });
  }
});

/**
 * Check if a concept is food-related
 * Since we're using the food-item-recognition model, most concepts should be food-related
 */
function isFoodRelated(concept: string): boolean {
  const conceptLower = concept.toLowerCase();
  
  // Since we're using the food-item-recognition model, we can be more permissive
  // Most concepts from this model should be food-related
  const nonFoodKeywords = [
    'person', 'people', 'man', 'woman', 'child', 'baby', 'face', 'hand', 'finger',
    'building', 'house', 'car', 'vehicle', 'road', 'street', 'tree', 'plant',
    'animal', 'dog', 'cat', 'bird', 'sky', 'cloud', 'water', 'ocean', 'sea',
    'mountain', 'hill', 'grass', 'flower', 'leaf', 'rock', 'stone', 'sand',
    'table', 'chair', 'plate', 'bowl', 'cup', 'glass', 'bottle', 'container',
    'text', 'word', 'letter', 'number', 'sign', 'logo', 'symbol', 'pattern',
    'color', 'red', 'blue', 'green', 'yellow', 'black', 'white', 'gray',
    'light', 'dark', 'shadow', 'reflection', 'mirror', 'window', 'door'
  ];
  
  // If it contains non-food keywords, it's probably not food
  const isNonFood = nonFoodKeywords.some(keyword => conceptLower.includes(keyword));
  
  // If it's not clearly non-food, assume it's food (since we're using food-item-recognition model)
  return !isNonFood;
}

export default router;

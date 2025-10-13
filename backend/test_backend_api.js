// Test script for the backend food recognition API
const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/food-recognition';

async function testBackendAPI() {
  console.log('🧪 Testing Backend Food Recognition API...\n');

  try {
    // Test 1: Health check
    console.log('1️⃣ Testing health endpoint...');
    const healthResponse = await axios.get('http://localhost:3000/health');
    console.log('✅ Health check:', healthResponse.data.message);
    console.log('');

    // Test 2: Test endpoint
    console.log('2️⃣ Testing food recognition test endpoint...');
    const testResponse = await axios.get(`${BASE_URL}/test`);
    console.log('✅ Test endpoint response:', testResponse.data);
    console.log('');

    // Test 3: URL-based recognition
    console.log('3️⃣ Testing URL-based food recognition...');
    const testImageUrl = "https://s3.amazonaws.com/samples.clarifai.com/featured-models/image-captioning-statue-of-liberty.jpeg";
    
    const urlResponse = await axios.post(`${BASE_URL}/recognize`, {
      imageUrl: testImageUrl
    });
    
    console.log('✅ URL recognition response:');
    console.log('   Success:', urlResponse.data.success);
    console.log('   Total concepts:', urlResponse.data.data.totalConcepts);
    console.log('   Food concepts:', urlResponse.data.data.foodConcepts);
    console.log('   Sample concepts:');
    
    urlResponse.data.data.concepts.slice(0, 5).forEach((concept, index) => {
      console.log(`     ${index + 1}. ${concept.name}: ${(concept.confidence * 100).toFixed(1)}%`);
    });
    
    // Show raw concepts for debugging
    console.log('   Raw concepts (first 3):');
    urlResponse.data.data.rawConcepts.slice(0, 3).forEach((concept, index) => {
      console.log(`     ${index + 1}. ${concept.name}: ${(concept.value * 100).toFixed(1)}%`);
    });
    console.log('');

    console.log('🎉 All tests passed! Backend API is working correctly.');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Data:', error.response.data);
    }
    
    if (error.code === 'ECONNREFUSED') {
      console.error('   💡 Make sure the backend server is running on port 3000');
      console.error('   💡 Run: cd backend && npm run dev');
    }
  }
}

// Run the test
testBackendAPI();

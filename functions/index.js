const functions = require('firebase-functions');
const axios = require('axios');

// Hugging Face API anahtarınız (güvenli değil, production için farklı bir yaklaşım kullanın)
// Firebase functions:config:set huggingface.key="YOUR_API_KEY" komutu ile ayarlayabilirsiniz
const HUGGING_FACE_API_KEY = functions.config().huggingface?.key || "API_KEY";

// Cilt ve Akciğer modelleri için Hugging Face model ID'leri
const SKIN_MODEL_ID = "nielsr/vit-finetuned-dermnet";
const LUNG_MODEL_ID = "keremberke/chest-xray-classification";

exports.analyzeImage = functions.https.onRequest(async (req, res) => {
  // CORS için header ayarları
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  // OPTIONS isteği için yanıt (CORS preflight)
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  // Sadece POST isteklerini kabul et
  if (req.method !== 'POST') {
    res.status(405).send({ success: false, error: 'Sadece POST metodu destekleniyor' });
    return;
  }
  
  try {
    // Request body'den verileri çıkar
    const { imageBase64, isSkinAnalysis } = req.body;
    
    if (!imageBase64) {
      res.status(400).send({ success: false, error: 'imageBase64 alanı gerekli' });
      return;
    }
    
    // Analiz türüne göre model seç
    const modelId = isSkinAnalysis ? SKIN_MODEL_ID : LUNG_MODEL_ID;
    
    // Hugging Face API'sine istek gönder
    const response = await axios.post(
      `https://api-inference.huggingface.co/models/${modelId}`,
      { 
        inputs: {
          image: imageBase64
        }
      },
      {
        headers: {
          'Authorization': `Bearer ${HUGGING_FACE_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    // Başarılı yanıt
    res.status(200).send({
      success: true,
      data: response.data
    });
  } catch (error) {
    // Hata durumunda
    console.error('Error:', error.message);
    res.status(500).send({
      success: false,
      error: `Analiz sırasında bir hata oluştu: ${error.message}`
    });
  }
}); 
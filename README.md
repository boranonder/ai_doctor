# AI Doctor

AI Doctor, cilt hastalıkları ve akciğer röntgenleri üzerinde yapay zeka ile tanı yapabilen bir mobil uygulamadır.

## Kurulum

1. Flutter'ı yükleyin ve ortam değişkenlerinizi ayarlayın
2. Repo'yu klonlayın
3. Bağımlılıkları yükleyin:
   ```
   flutter pub get
   ```

## Firebase Kurulumu

Firebase projesini ayarlamak için aşağıdaki adımları izleyin:

1. [Firebase Console](https://console.firebase.google.com/) üzerinden yeni bir proje oluşturun
2. Android ve iOS uygulamalarınızı Firebase projenize ekleyin
3. Firebase CLI'ı kurun ve projenizde oturum açın:
   ```
   npm install -g firebase-tools
   firebase login
   ```
4. Proje dizininde Firebase'i başlatın:
   ```
   firebase init
   ```
   - Firestore ve Functions'ı seçin
   - Yeni bir proje seçin ve oluşturduğunuz Firebase projesini seçin
   - JavaScript'i seçin ve ESLint'i kullanmayı kabul edin
   - Mevcut dosyaların üzerine yazmayın

5. Cloud Functions'ı kurun ve dağıtın:
   ```
   cd functions
   npm install
   firebase deploy --only functions
   ```

6. Firebase Fonksiyon URL'sini kopyalayın ve `lib/services/api_service.dart` dosyasındaki `_functionUrl` değişkenini güncelleyin.

## API Anahtarı Yapılandırması

Projedeki API anahtarlarını güvenli bir şekilde saklamak için:

1. Hugging Face API anahtarınızı Firebase Environment Config'de saklayın:
```
firebase functions:config:set huggingface.key="YOUR_HUGGINGFACE_API_KEY"
firebase deploy --only functions
```

2. OpenAI API anahtarınızı güncelleyin:
- `lib/services/openai_service.dart` dosyasındaki `_apiKey` değişkenini kendi API anahtarınızla değiştirin veya API anahtarınızı Firebase Config'de saklayın.

3. Firebase Config dosyalarını güncelleyin:
- iOS: `ios/Runner/GoogleService-Info.plist` dosyasını kendi Firebase projenizden indirdiğiniz dosya ile değiştirin
- Android: `android/app/google-services.json` dosyasını kendi Firebase projenizden indirdiğiniz dosya ile değiştirin

## Uygulamayı Çalıştırma

```
flutter run
```

## Özellikler

- Cilt hastalıkları ve akciğer röntgeni analizi
- Kamera veya galeri üzerinden görüntü seçimi
- Detaylı analiz sonuçları
- Türkçe arayüz

## Güvenlik

Bu uygulama, hassas API anahtarlarını Firebase Cloud Functions üzerinde saklamak için tasarlanmıştır. API anahtarlarını doğrudan mobil uygulamaya dahil etmekten kaçının.

**Önemli:** Gerçek bir üretim ortamında:
1. Tüm API anahtarlarını sunucu tarafında (Firebase Functions gibi) saklayın
2. API isteklerini doğrudan kullanıcı arayüzünden değil, sunucu üzerinden yapın
3. Firebase ve diğer servis yapılandırma dosyalarını `.gitignore` dosyasına ekleyin
4. Projeyi GitHub'a yüklemeden önce tüm hassas bilgileri temizleyin

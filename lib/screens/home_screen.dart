import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/analysis_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), // Açık turkuaz arka plan
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF00BCD4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logos/ChatGPT Image 2 May 2025 17_20_56.png',
                    width: 120,
                    height: 120,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Select Analysis Type',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAnalysisOption(
                        context,
                        'Skin Analysis',
                        'Analyze skin conditions using AI',
                        Icons.face,
                        AnalysisType.skin,
                      ),
                      const SizedBox(height: 16),
                      _buildAnalysisOption(
                        context,
                        'Lung X-Ray Analysis',
                        'Analyze lung X-ray images using AI',
                        Icons.medical_services,
                        AnalysisType.lung,
                      ),
                      const SizedBox(height: 16),
                      _buildAnalysisOption(
                        context,
                        'Brain MRI Analysis',
                        'Analyze brain MRI scans using AI',
                        Icons.psychology,
                        AnalysisType.brain,
                      ),
                      const SizedBox(height: 16),
                      _buildAnalysisOption(
                        context,
                        'Eye Retina Analysis',
                        'Analyze eye retina images using AI',
                        Icons.visibility,
                        AnalysisType.eye,
                      ),
                      const SizedBox(height: 16),
                      _buildAnalysisOption(
                        context,
                        'Dental Analysis',
                        'Analyze dental X-rays and images using AI',
                        Icons.sentiment_very_satisfied,
                        AnalysisType.dental,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AnalysisType type,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 32,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00838F),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _pickImage(context, type, ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Select from Gallery'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context, AnalysisType type, ImageSource source) async {
    final provider = context.read<AnalysisProvider>();
    provider.setAnalysisType(type);
    await provider.pickImage(source);
    
    if (provider.selectedImage != null && context.mounted) {
      _showImagePreview(context, provider);
    }
  }

  void _showImagePreview(BuildContext context, AnalysisProvider provider) {
    String previewTitle;
    switch (provider.analysisType) {
      case AnalysisType.skin:
        previewTitle = 'Skin Image Preview';
        break;
      case AnalysisType.lung:
        previewTitle = 'Lung X-Ray Preview';
        break;
      case AnalysisType.brain:
        previewTitle = 'Brain MRI Preview';
        break;
      case AnalysisType.eye:
        previewTitle = 'Eye Retina Preview';
        break;
      case AnalysisType.dental:
        previewTitle = 'Dental Image Preview';
        break;
      default:
        previewTitle = 'Image Preview';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 5,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                previewTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    provider.selectedImage!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.reset();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF00BCD4)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.analyzeImage();
                        Navigator.pop(context);
                        _showAnalysisResult(context, provider);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Analyze'),
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

  void _showAnalysisResult(BuildContext context, AnalysisProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Analysis Result',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (provider.selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        provider.selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: provider.isAnalyzing
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Analyzing image...\nThis may take a moment.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : provider.analysisResult != null
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (provider.modelResult != null) ...[
                                  const Text(
                                    'Model Analysis:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F7FA),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF80DEEA)),
                                    ),
                                    child: Text(
                                      provider.modelResult!,
                                      style: const TextStyle(
                                        height: 1.5,
                                        fontFamily: 'Roboto',
                                        fontSize: 15,
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                  ),
                                ],
                                const Text(
                                  'Detailed Analysis:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    provider.analysisResult!,
                                    style: const TextStyle(
                                      height: 1.5,
                                      fontFamily: 'Roboto',
                                      fontSize: 15,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: Text('No analysis results yet.'),
                          ),
                  ),
                  if (!provider.isAnalyzing && provider.analysisResult == null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        provider.analyzeImage();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Analyze'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'ai_service.dart'; 
import 'api_service.dart';

class PreviewEditScreen extends StatefulWidget {
  final String imagePath;
  final List<String> tickets;

  const PreviewEditScreen({
    super.key,
    required this.imagePath,
    required this.tickets,
  });

  @override
  _PreviewEditScreenState createState() => _PreviewEditScreenState();
}

class _PreviewEditScreenState extends State<PreviewEditScreen> {
  late String _currentImagePath;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = List.generate(7, (index) => FocusNode());
  int currentQuestionIndex = 0;
  bool _isProcessing = false;
  bool _analysisComplete = false;
  Map<String, dynamic> _analysisResults = {};
  
  final SkinLesionAnalyzer _aiService = SkinLesionAnalyzer();
  final ApiService _apiService = ApiService();

  final List<QuestionModel> _questions = [
    QuestionModel(
      question: 'Location:',
      type: QuestionType.multipleChoice,
      options: ['Head', 'Torso', 'Arms', 'Legs', 'Other'],
      isRequired: true,
    ),
    QuestionModel(
      question: 'Painful?',
      type: QuestionType.multipleChoice,
      options: ['Yes', 'No'],
      isRequired: true,
    ),
    QuestionModel(
      question: 'Itching?',
      type: QuestionType.multipleChoice,
      options: ['Yes', 'No'],
      isRequired: true,
    ),
    QuestionModel(
      question: 'Duration (days):',
      type: QuestionType.text,
      isRequired: true,
      inputType: TextInputType.number,
    ),
    QuestionModel(
      question: 'Color change?',
      type: QuestionType.multipleChoice,
      options: ['Yes - Darker', 'Yes - Lighter', 'No', 'Other'],
      isRequired: true,
    ),
    QuestionModel(
      question: 'Size change?',
      type: QuestionType.multipleChoice,
      options: ['Yes - Bigger', 'Yes - Smaller', 'No', 'Other'],
      isRequired: true,
    ),
    QuestionModel(
      question: 'Number of lesions:',
      type: QuestionType.text,
      isRequired: true,
      inputType: TextInputType.number,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      await _aiService.loadModels();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading AI models: $e')),
        );
      }
    }
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentImagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.blue,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _currentImagePath = croppedFile.path;
      });
    }
  }

  void _nextQuestion() {
    if (_formKey.currentState!.validate()) {
      if (currentQuestionIndex < _questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
        });
      }
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Show a loading indicator for at least 1 second to improve UX
      await Future.delayed(const Duration(seconds: 1));
      
      final results = await _aiService.analyze(File(_currentImagePath));

      if (results['status'] == 'success') {
        setState(() {
          _analysisResults = results;
          _analysisComplete = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(results['message'] ?? 'Analysis failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during analysis: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      if (!_analysisComplete) {
        await _analyzeImage();
      }
      
      if (!_analysisComplete) {
        return; // Analysis failed
      }
      
      setState(() {
        _isProcessing = true;
      });
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final patientId = prefs.getString('patient_id') ?? 'unknown';
        
        final serverImagePath = await _apiService.uploadImage(File(_currentImagePath));
        
        Map<String, dynamic> symptomData = {};
        for (var question in _questions) {
          if (question.type == QuestionType.multipleChoice) {
            symptomData[question.question] = question.answer;
            if (question.answer == 'Other') {
              symptomData['${question.question} details'] = question.detailsController.text;
            }
          } else {
            symptomData[question.question] = question.textController.text;
          }
        }
        
        final String diagnosisResult = 
            _analysisResults['diagnosis'] ?? 'UNKNOWN';
        
        await _apiService.saveMedicalImage(
          patientId: patientId,
          imagePath: serverImagePath,
          primaryScore: _analysisResults['primary_score'] ?? 0.0,
          secondaryScore: _analysisResults['secondary_score'] ?? 0.0,
          lesionType: _analysisResults['lesion_type'] ?? 'unknown',
          priority: _analysisResults['priority'] ?? 0,
          doctorNotes: json.encode(symptomData),
          diagnosisResult: diagnosisResult,
        );
        
        widget.tickets.add(_currentImagePath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis submitted successfully')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting analysis: $e')),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review and Submit'),
        backgroundColor: Colors.blue[700],
        elevation: 2,
      ),
      body: _isProcessing
          ? _buildLoadingView()
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                height: 240,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: PhotoView(
                                    imageProvider: FileImage(File(_currentImagePath)),
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale: PhotoViewComputedScale.covered * 2,
                                    backgroundDecoration: BoxDecoration(
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: FloatingActionButton(
                                  onPressed: _cropImage,
                                  backgroundColor: Colors.blue,
                                  mini: true,
                                  child: const Icon(Icons.crop),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                           if (_analysisComplete) _buildAnalysisResults(),
                           if (!_analysisComplete) 
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.science),
                                label: const Text('Analyze Image'),
                                onPressed: _analyzeImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ),
                           const SizedBox(height: 24),
                          // Questions Section
                          Text(
                            'Question ${currentQuestionIndex + 1} of ${_questions.length}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildQuestion(_questions[currentQuestionIndex]),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentQuestionIndex > 0)
                                OutlinedButton(
                                  onPressed: _previousQuestion,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: BorderSide(color: Colors.blue),
                                  ),
                                  child: const Text('Previous'),
                                ),
                              const Spacer(),
                              if (currentQuestionIndex < _questions.length - 1)
                                ElevatedButton(
                                  onPressed: _nextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text('Next'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _analysisComplete ? _submitTicket : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[700],
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        _analysisComplete ? 'Submit Ticket' : 'Analyze Image First',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitRipple(
            color: Colors.blue[700]!,
            size: 100.0,
          ),
          const SizedBox(height: 24),
          Text(
            'Processing image...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This may take a few moments as we analyze your skin lesion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    // Using null-aware operators for safe access
    int priority = _analysisResults['priority'] ?? 0;
    Color riskColor;
    String riskLevel;
    IconData riskIcon;
    
    if (priority == 2) {
      riskColor = Colors.red;
      riskLevel = "High Risk";
      riskIcon = Icons.warning;
    } else if (priority == 1) {
      riskColor = Colors.orange;
      riskLevel = "Medium Risk";
      riskIcon = Icons.info;
    } else {
      riskColor = Colors.green;
      riskLevel = "Low Risk";
      riskIcon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: riskColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(riskIcon, color: riskColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'AI Analysis Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagnosis:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _analysisResults['diagnosis'] ?? 'Unknown',
                style: TextStyle(
                  color: _analysisResults['diagnosis'] == 'MALIGNANT' ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lesion Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _analysisResults['lesion_type'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Risk Level:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  riskLevel,
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confidence:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${((_analysisResults['secondary_score'] ?? 0.0)*100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: This is an AI analysis and not a medical diagnosis. Please consult with a healthcare professional.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(QuestionModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (question.type == QuestionType.multipleChoice)
          Column(
            children: question.options.map((option) {
              return RadioListTile(
                activeColor: Colors.blue,
                title: Text(option),
                value: option,
                groupValue: question.answer,
                onChanged: (value) {
                  setState(() {
                    question.answer = value!;
                    if (value == 'Other') {
                      question.detailsController.text = '';
                    } else {
                      question.detailsController.clear();
                    }
                  });
                },
              );
            }).toList(),
          ),
        if (question.answer == 'Other' && question.type == QuestionType.multipleChoice)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: TextFormField(
              controller: question.detailsController,
              focusNode: _focusNodes[currentQuestionIndex],
              decoration: const InputDecoration(
                labelText: 'Specify details',
                hintText: 'Please describe...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter details';
                }
                return null;
              },
            ),
          ),
        if (question.type == QuestionType.text)
          TextFormField(
            controller: question.textController,
            focusNode: _focusNodes[currentQuestionIndex],
            keyboardType: question.inputType,
            decoration: InputDecoration(
              labelText: question.question,
              hintText: 'Enter ${question.question.toLowerCase()}',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (question.inputType == TextInputType.number &&
                  double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
      ],
    );
  }
}

enum QuestionType { multipleChoice, text }

class QuestionModel {
  final String question;
  final QuestionType type;
  final List<String> options;
  final bool isRequired;
  final TextInputType inputType;
  String answer;
  final TextEditingController textController;
  final TextEditingController detailsController;

  QuestionModel({
    required this.question,
    required this.type,
    this.options = const [],
    this.isRequired = false,
    this.inputType = TextInputType.text,
  })  : answer = '',
        textController = TextEditingController(),
        detailsController = TextEditingController();
}
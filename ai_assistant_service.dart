import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class AiAssistantService {
  final String _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  AiAssistantService({required String apiKey}) : _apiKey = apiKey;

  // Mock implementation for development
  Future<String> getMockResponse(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final queryLower = query.toLowerCase();
    
    if (queryLower.contains('आज') && queryLower.contains('कुल') && 
        (queryLower.contains('संग्रह') || queryLower.contains('कलेक्शन'))) {
      return "आज का कुल दूध संग्रह 2450 किलो है। कुल राशि ₹98,500 है।";
    }
    
    if (queryLower.contains('किसान') && queryLower.contains('संख्या')) {
      return "कुल पंजीकृत किसानों की संख्या: 85";
    }
    
    if (queryLower.contains('सुबह') && queryLower.contains('संग्रह')) {
      return "सुबह की पारी में 1350 किलो दूध संग्रह हुआ।";
    }
    
    if (queryLower.contains('शाम') && queryLower.contains('संग्रह')) {
      return "शाम की पारी में 1100 किलो दूध संग्रह हुआ।";
    }
    
    if (queryLower.contains('दर') && queryLower.contains('चार्ट')) {
      return "वर्तमान दर चार्ट:\nगाय दूध: ₹40/किलो (बेस)\nभैंस दूध: ₹50/किलो (बेस)\nफैट: ₹2.5 प्रति यूनिट\nएसएनएफ: ₹1.5 प्रति यूनिट";
    }
    
    return "मैं आपकी डेयरी सहायक हूं। आप मुझसे दूध संग्रह, रिपोर्ट्स, दर चार्ट आदि के बारे में पूछ सकते हैं।";
  }

  // Real Gemini API integration
  Future<String> getAiResponse(String query, {Map<String, dynamic>? context}) async {
    if (_apiKey.isEmpty || kDebugMode) {
      // Use mock in debug mode or if no API key
      return getMockResponse(query);
    }

    try {
      final url = '$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey';
      
      final prompt = '''
        You are a dairy management assistant for Indian farmers. 
        Respond in Hindi (Devanagari script).
        
        Context: ${context != null ? jsonEncode(context) : 'No specific context'}
        
        User Query: $query
        
        Provide a helpful, concise response in Hindi.
      ''';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List;
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List;
          if (parts.isNotEmpty) {
            return parts[0]['text'];
          }
        }
        return 'कुछ त्रुटि हुई है। कृपया पुनः प्रयास करें।';
      } else {
        return 'API कनेक्शन त्रुटि। मॉक प्रतिक्रिया: ${await getMockResponse(query)}';
      }
    } catch (e) {
      debugPrint('AI API Error: $e');
      return await getMockResponse(query);
    }
  }

  // Context builder for AI
  Map<String, dynamic> buildContext({
    required double todayCollection,
    required double todayAmount,
    required int totalFarmers,
    required Map<String, dynamic> rateChart,
  }) {
    return {
      'today_collection_kg': todayCollection,
      'today_amount_rs': todayAmount,
      'total_farmers': totalFarmers,
      'rate_chart': rateChart,
      'current_date': DateTime.now().toIso8601String(),
    };
  }
}

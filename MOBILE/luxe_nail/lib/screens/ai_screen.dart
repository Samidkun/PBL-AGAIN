import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  const AIScreen({super.key, required this.token, required this.user});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _loading = false;
  String? _generatedImage; // base64 string

  Future<void> generateImage() async {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prompt")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final apiKey = dotenv.env['OPENROUTER_API_KEY'];
      final model = dotenv.env['AI_MODEL'];

      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {"role": "user", "content": "Generate image: $prompt"}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final content = data["choices"][0]["message"]["content"];

        setState(() {
          _generatedImage = content;
        });
      } else {
        print("API Error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEAEE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEAEE),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "AI Nail Design",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF451A2B),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF451A2B)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ Title
            const Text(
              "Create Nail Designs with AI 💅✨",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF451A2B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 15),

            // ✨ TextField
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFFF8F9),
                hintText: "e.g. Natural matte red nails with soft lighting",
                hintStyle: const TextStyle(color: Color(0xFFAF7C85)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFAF7C85)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF975B73), width: 2),
                ),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 20),

            // ✨ Generate Button
            Center(
              child: GestureDetector(
                onTap: _loading ? null : generateImage,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAF7C85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: _loading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Generating...",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        )
                      : const Text(
                          "Generate Design",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✨ Image Result
            if (_generatedImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Generated Result",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF451A2B),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // image base64
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      base64Decode(_generatedImage!.split(',').last),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

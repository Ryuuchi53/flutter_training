import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_training_full/app_drawer.dart';

class FilmScreen extends StatefulWidget {
  final String email;
  final String name;

  const FilmScreen({super.key, required this.email, required this.name});

  @override
  State<FilmScreen> createState() => _FilmScreenState();
}

class _FilmScreenState extends State<FilmScreen> {
  List films = [];

  bool isLoading = true;
  bool isChangingPage = false;

  int page = 1;
  final int pageSize = 5;

  bool hasMoreNext = true;

  @override
  void initState() {
    super.initState();
    fetchPage();
  }

  Future<void> fetchPage() async {
    setState(() {
      isLoading = true;
      page = 1;
      hasMoreNext = true;
      films = []; // optional: clears old list instantly
    });

    await _fetchData();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> goToNextPage() async {
    if (isChangingPage || !hasMoreNext) return;

    setState(() {
      isChangingPage = true;
      page++;
    });

    await _fetchData();

    setState(() {
      isChangingPage = false;
    });
  }

  Future<void> goToPreviousPage() async {
    if (isChangingPage || page == 1) return;

    setState(() {
      isChangingPage = true;
      page--;
    });

    await _fetchData();

    setState(() {
      isChangingPage = false;
    });
  }

  Future<void> _fetchData() async {
    final url = Uri.parse('https://ghibliapi.vercel.app/films');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        // simulate pagination manually (API has no real pagination)
        final start = (page - 1) * pageSize;
        final end = start + pageSize;

        List newFilms = data.sublist(
          start,
          end > data.length ? data.length : end,
        );

        setState(() {
          films = newFilms;
          hasMoreNext = end < data.length;
        });
      } else {
        hasMoreNext = false;
      }
    } catch (e) {
      hasMoreNext = false;
    }
  }

  Widget buildImage(String? imageUrl) {
    const radius = BorderRadius.vertical(top: Radius.circular(12));

    final isValidUrl =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

    Widget imageWidget;

    if (isValidUrl) {
      imageWidget = Image.network(
        imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return _noImagePlaceholder();
        },
      );
    } else {
      imageWidget = _noImagePlaceholder();
    }

    return ClipRRect(borderRadius: radius, child: imageWidget);
  }

  Widget _noImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40),
          SizedBox(height: 6),
          Text(
            "No Image Available",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchPage),
        ],
      ),

      drawer: AppDrawer(
        currentRoute: '/films',
        prefilledEmail: widget.email,
        prefilledName: widget.name,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF8E2DE2), Color(0xFFDA22FF)],
          ),
        ),

        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white.withValues(alpha: 0.95),
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                ),
              )
            : Column(
                children: [
                  /// 📜 LIST
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: films.length,
                      itemBuilder: (context, index) {
                        final film = films[index];

                        return Card(
                          color: Colors.white.withValues(alpha: 0.9),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildImage(film['image']),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      film['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${film['original_title'] ?? ''} (${film['original_title_romanised'] ?? ''})',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      film['description'] ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Release Date: ${film['release_date'] ?? 'Unknown'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  /// 🔘 PAGINATION CONTROLS (same as MenuScreen)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: (page > 1 && !isChangingPage)
                              ? goToPreviousPage
                              : null,
                          child: isChangingPage && page > 1
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_back),
                        ),

                        Text(
                          "Page $page",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        ElevatedButton(
                          onPressed: (hasMoreNext && !isChangingPage)
                              ? goToNextPage
                              : null,
                          child: isChangingPage
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

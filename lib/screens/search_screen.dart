import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/conditions_data.dart';
import '../models/condition.dart';
import 'condition_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Condition> _results = [];

  List<Condition> get _allConditions =>
      allBodyParts.expand((p) => p.conditions).toList();

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _results = _allConditions.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.symptoms.any((s) => s.toLowerCase().contains(q)) ||
            c.bodyPart.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E86AB),
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onSearch,
          style: GoogleFonts.poppins(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search symptoms, conditions, body part...',
            hintStyle: GoogleFonts.poppins(color: Colors.white60, fontSize: 14),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _controller.clear();
                _onSearch('');
              },
            ),
        ],
      ),
      body: _results.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) =>
                  _SearchResultTile(condition: _results[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _controller.text.isEmpty
                ? 'Type to search conditions or symptoms'
                : 'No results found',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Condition condition;
  const _SearchResultTile({required this.condition});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConditionDetailScreen(condition: condition),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: condition.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFECF0F1),
                    child: const Icon(Icons.image_outlined,
                        color: Colors.grey, size: 20)),
                errorWidget: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFECF0F1),
                    child: const Icon(Icons.broken_image_outlined,
                        color: Colors.grey, size: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1A2E3B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    condition.bodyPart,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: const Color(0xFF2E86AB)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

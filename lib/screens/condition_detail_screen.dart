import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/condition.dart';

class ConditionDetailScreen extends StatelessWidget {
  final Condition condition;
  const ConditionDetailScreen({super.key, required this.condition});

  Color get _severityColor {
    switch (condition.severity) {
      case 'mild':     return const Color(0xFF27AE60);
      case 'moderate': return const Color(0xFFF39C12);
      case 'severe':   return const Color(0xFFE74C3C);
      default:         return Colors.grey;
    }
  }

  IconData get _severityIcon {
    switch (condition.severity) {
      case 'mild':     return Icons.check_circle_outline;
      case 'moderate': return Icons.warning_amber_outlined;
      case 'severe':   return Icons.error_outline;
      default:         return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeverityBadge(),
                  const SizedBox(height: 12),
                  _buildConsensusRating(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.visibility_outlined,
                    title: 'Visual Symptoms',
                    color: const Color(0xFF2E86AB),
                    items: condition.symptoms,
                    bulletColor: const Color(0xFF2E86AB),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    icon: Icons.medical_services_outlined,
                    title: 'Recommendations',
                    color: const Color(0xFF27AE60),
                    items: condition.recommendations,
                    bulletColor: const Color(0xFF27AE60),
                  ),
                  if (condition.sources.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSources(),
                  ],
                  const SizedBox(height: 20),
                  _buildDisclaimer(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF2E86AB),
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          condition.name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: condition.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF2E86AB)),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF2E86AB),
                child: const Icon(Icons.broken_image_outlined,
                    color: Colors.white54, size: 60),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC1A2E3B)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _severityColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_severityIcon, color: _severityColor, size: 16),
          const SizedBox(width: 6),
          Text(
            '${condition.severity[0].toUpperCase()}${condition.severity.substring(1)} severity  •  ${condition.bodyPart}',
            style: GoogleFonts.poppins(
              color: _severityColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsensusRating() {
    final score = condition.consensusScore;
    final label = condition.consensusLabel;
    final starColor = score >= 4
        ? const Color(0xFF2E86AB)
        : score == 3
            ? const Color(0xFFF39C12)
            : const Color(0xFF95A5A6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Consensus',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < score ? starColor : Colors.grey[300],
                  size: 20,
                )),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: starColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      condition.description,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: const Color(0xFF374151),
        height: 1.6,
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> items,
    required Color bulletColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF1A2E3B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: bulletColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSources() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E86AB).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: Color(0xFF2E86AB), size: 16),
              const SizedBox(width: 6),
              Text(
                'Verified Sources',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E86AB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...condition.sources.map((s) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  '• $s',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF374151),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF39C12).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF39C12), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This app provides general information only and is not a substitute for professional medical advice. '
              'Always consult a qualified healthcare provider for diagnosis and treatment.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF7D6500),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

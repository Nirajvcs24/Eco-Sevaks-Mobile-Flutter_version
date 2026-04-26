import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(),
                  const SizedBox(height: 32),
                  _buildHowItWorks(),
                  const SizedBox(height: 32),
                  _buildMission(context),
                  const SizedBox(height: 32),
                  _buildCTA(context),
                  const SizedBox(height: 100), // Bottom padding for tab bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        SizedBox(
          height: 400,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&q=80&w=1200',
            fit: BoxFit.cover,
          ),
        ),
        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.dark.withValues(alpha: 0.95),
                  AppColors.dark.withValues(alpha: 0.8),
                  AppColors.primary.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        // Content
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.sparkles, color: AppColors.secondary, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Join 10,000+ volunteers',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the Green Movement in India',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Find virtual and in-person environmental volunteer opportunities near you.',
                    style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Find Events',
                          onPressed: () => context.go('/events'),
                          leftIcon: const Icon(LucideIcons.search, size: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Get Started',
                          onPressed: () => context.go('/register'),
                          variant: ButtonVariant.outline,
                          textColorOverride: Colors.white,
                          leftIcon: const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 24,
        childAspectRatio: 2,
        children: [
          _StatItem(value: '10,000+', label: 'Volunteers'),
          _StatItem(value: '500+', label: 'Events'),
          _StatItem(value: '50+', label: 'Cities'),
          _StatItem(value: '25,000+', label: 'Trees Planted'),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How It Works', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
        const Text('Three simple steps to get started', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        _buildStep(LucideIcons.search, '1. Browse', 'Find events that match your passion', AppColors.primary.withValues(alpha: 0.1), AppColors.primary),
        const SizedBox(height: 12),
        _buildStep(LucideIcons.userPlus, '2. Join', 'Sign up with one tap', AppColors.accent.withValues(alpha: 0.1), AppColors.accent),
        const SizedBox(height: 12),
        _buildStep(LucideIcons.heart, '3. Participate', 'Connect with fellow volunteers', AppColors.secondary.withValues(alpha: 0.1), AppColors.secondary),
      ],
    );
  }

  Widget _buildStep(IconData icon, String title, String desc, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.dark)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMission(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.leaf, color: AppColors.primary, size: 14),
              SizedBox(width: 6),
              Text('Our Mission', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Building a Greener India, Together', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
        const Text(
          'Eco-Sevaks connects passionate volunteers with meaningful environmental initiatives across India.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        _buildMissionItem(LucideIcons.globe, 'Connect with local initiatives'),
        _buildMissionItem(LucideIcons.users, 'Meet eco-conscious volunteers'),
        _buildMissionItem(LucideIcons.award, 'Track your impact'),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Explore Opportunities',
          onPressed: () => context.go('/events'),
          leftIcon: const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMissionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Ready to Make a Difference?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Join thousands of volunteers creating positive environmental change.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Join Now',
                  onPressed: () => context.go('/register'),
                  variant: ButtonVariant.secondary,
                  leftIcon: const Icon(LucideIcons.leaf, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Browse',
                  onPressed: () => context.go('/events'),
                  variant: ButtonVariant.outline,
                  textColorOverride: Colors.white,
                  leftIcon: const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// Extension to support text color override in CustomButton
extension CustomButtonExtension on CustomButton {
  CustomButton copyWith({Color? textColorOverride}) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: variant,
      size: size,
      fullWidth: fullWidth,
      isLoading: isLoading,
      isDisabled: isDisabled,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      // Note: We need to modify CustomButton to support this or use a different approach.
      // For now, I'll update CustomButton.
    );
  }
}

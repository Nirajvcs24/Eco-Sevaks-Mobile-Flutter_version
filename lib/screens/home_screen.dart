import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/count_up_text.dart';
import '../widgets/liquid_glass_container.dart';
import '../widgets/fade_in_up.dart';

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
                  _buildHowItWorks(context),
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
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
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
                  ),
                  const SizedBox(height: 16),
                  const FadeInUp(
                    delay: Duration(milliseconds: 400),
                    child: Text(
                      'Join the Green Movement in India',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FadeInUp(
                    delay: Duration(milliseconds: 600),
                    child: Text(
                      'Find virtual and in-person environmental volunteer opportunities near you.',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Find Events',
                            onPressed: () => context.push('/events'),
                            leftIcon: const Icon(LucideIcons.search, size: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Get Started',
                            onPressed: () => context.push('/dashboard'),
                            variant: ButtonVariant.outline,
                            textColorOverride: Colors.white,
                            leftIcon: const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
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
    return FadeInUp(
      delay: const Duration(milliseconds: 1000),
      child: LiquidGlassContainer(
        blur: 20,
        opacity: 0.7,
        gradientColors: [AppColors.paleGreen, AppColors.paleGreen],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            childAspectRatio: 2,
            children: [
              _StatItem(value: '10,000', label: 'Volunteers', suffix: '+'),
              _StatItem(value: '500', label: 'Events', suffix: '+'),
              _StatItem(value: '50', label: 'Cities', suffix: '+'),
              _StatItem(value: '25,000', label: 'Trees Planted', suffix: '+'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How It Works', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        Text('Three simple steps to get started', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 16),
        _buildStep(context, LucideIcons.search, '1. Browse', 'Find events that match your passion', AppColors.primary.withValues(alpha: 0.1), AppColors.primary),
        const SizedBox(height: 12),
        _buildStep(context, LucideIcons.userPlus, '2. Join', 'Sign up with one tap', AppColors.accent.withValues(alpha: 0.1), AppColors.accent),
        const SizedBox(height: 12),
        _buildStep(context, LucideIcons.heart, '3. Participate', 'Connect with fellow volunteers', AppColors.secondary.withValues(alpha: 0.1), AppColors.secondary),
      ],
    );
  }

  Widget _buildStep(BuildContext context, IconData icon, String title, String desc, Color bgColor, Color iconColor) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface)),
                Text(desc, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMission(BuildContext context) {
    final theme = Theme.of(context);
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
        Text('Building a Greener India, Together', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        Text(
          'Eco-Sevaks connects passionate volunteers with meaningful environmental initiatives across India.',
          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 16),
        _buildMissionItem(context, LucideIcons.globe, 'Connect with local initiatives'),
        _buildMissionItem(context, LucideIcons.users, 'Meet eco-conscious volunteers'),
        _buildMissionItem(context, LucideIcons.award, 'Track your impact'),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Explore Opportunities',
          onPressed: () => context.push('/events'),
          leftIcon: const Icon(LucideIcons.arrowRight, size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMissionItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
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
          Text(text, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.8))),
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
                  onPressed: () => context.go('/profile'),
                  variant: ButtonVariant.secondary,
                  leftIcon: const Icon(LucideIcons.leaf, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Browse',
                  onPressed: () => context.push('/events'),
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
  final String suffix;

  const _StatItem({required this.value, required this.label, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CountUpText(
          value: value,
          suffix: suffix,
          style: TextStyle(color: isDark ? Colors.white : AppColors.dark, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


